import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from openai import OpenAI
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime, UTC
from bson import ObjectId
import json
import certifi

# Local Model Handler (for offline/edge inference)
# Uncomment to enable local GGUF model support
# from local_model import get_local_model

# Load API Keys
load_dotenv()

# --- Multi-Agent Architecture Setup ---
# The system uses different "agent roles" with specialized prompts:
# 1. Opponent Agent - Adaptive negotiator (uses MAIN_MODEL)
# 2. Shadow Coach Agent - Real-time tips (uses COACH_MODEL)  
# 3. Post-Session Analyst - Deep analysis (uses MAIN_MODEL)
# 4. Local Model Agent - Fallback for offline scenarios (optional)

# Check if local model is enabled
USE_LOCAL_MODEL = os.getenv("USE_LOCAL_MODEL", "false").lower() == "true"

if USE_LOCAL_MODEL:
    # Local GGUF Model Mode
    print("🔧 Local Model Mode: Enabled")
    print("   Model: ncert-phi-1_5-q4_k_m.gguf")
    # local_model = get_local_model()
    # if not local_model:
    #     print("⚠️  Local model failed to load, falling back to cloud APIs")
    #     USE_LOCAL_MODEL = False
else:
    # Cloud API Mode (Groq/OpenAI)
    api_key = os.getenv("OPENAI_API_KEY") or os.getenv("GROQ_API_KEY")
    if not api_key:
        raise RuntimeError("Missing API key")

    # Detect API Provider
    is_groq = api_key.startswith("gsk_")
    if is_groq:
        client = OpenAI(api_key=api_key, base_url="https://api.groq.com/openai/v1")
        MAIN_MODEL = "llama-3.3-70b-versatile"  # For Opponent & Analyst agents
        COACH_MODEL = "llama-3.1-8b-instant"     # For Coach agent (faster)
        print("✅ Cloud API Mode: Groq")
    else:
        client = OpenAI(api_key=api_key)
        MAIN_MODEL = "gpt-4-turbo"
        COACH_MODEL = "gpt-3.5-turbo"
        print("✅ Cloud API Mode: OpenAI")

# MongoDB Setup
MONGODB_URL = os.getenv("MONGODB_URL")
if not MONGODB_URL:
    raise RuntimeError("Missing MONGODB_URL in environment")

mongo_client = AsyncIOMotorClient(MONGODB_URL, tlsCAFile=certifi.where())
db = mongo_client.negotiation_db
sessions_collection = db.sessions

app = FastAPI()

# --- Models ---
class ChatMessage(BaseModel):
    role: str
    content: str

class NegotiationRequest(BaseModel):
    scenario: str
    history: List[ChatMessage]
    current_leverage: float
    session_id: Optional[str] = None

class NegotiationResponse(BaseModel):
    opponent_reply: str
    coach_tip: str
    new_leverage: float
    new_mood: str
    session_id: str

# --- 1. Opponent Brain ---
def get_opponent_response(scenario, history):
    system_prompt = f"You are a tough negotiator in a {scenario}. Be realistic, concise (max 3 sentences), and react to user tone."
    messages = [{"role": "system", "content": system_prompt}] + [{"role": m.role, "content": m.content} for m in history]
    response = client.chat.completions.create(model=MAIN_MODEL, messages=messages)
    return response.choices[0].message.content

# --- 2. Coach Brain ---
def get_coach_tip(last_user_msg):
    prompt = f"Analyze: '{last_user_msg}'. Give 1 short tactical tip (max 15 words)."
    response = client.chat.completions.create(model=COACH_MODEL, messages=[{"role": "user", "content": prompt}])
    return response.choices[0].message.content

# --- 3. Analysis Brain (NEW) ---
def generate_analysis(history_text, scenario):
    prompt = f"""
    Analyze this negotiation transcript for: "{scenario}".
    Transcript:
    {history_text}
    
    Return valid JSON with:
    - summary: 2 sentences on performance.
    - outcome: "Success" or "Failure" (did they get a good deal?).
    - strengths: List of objects {{ "point": "Short Title", "explanation": "Details" }}.
    - mistakes: List of objects {{ "point": "Short Title", "explanation": "Details" }}.
    - skill_gaps: List of strings (e.g. "Anchoring", "Active Listening").
    """
    try:
        response = client.chat.completions.create(
            model=MAIN_MODEL,
            messages=[{"role": "system", "content": "You are a negotiation coach. Output strictly valid JSON."}, 
                      {"role": "user", "content": prompt}],
            response_format={"type": "json_object"}
        )
        return json.loads(response.choices[0].message.content)
    except:
        # Fallback if JSON fails
        return {
            "summary": "Analysis failed to generate.",
            "outcome": "Neutral",
            "strengths": [],
            "mistakes": [],
            "skill_gaps": []
        }

# --- Endpoints ---

@app.post("/negotiate", response_model=NegotiationResponse)
async def negotiate(request: NegotiationRequest):
    reply = get_opponent_response(request.scenario, request.history)
    tip = get_coach_tip(request.history[-1].content)
    
    # Simple leverage logic
    new_lev = request.current_leverage + (0.05 if "yes" in reply.lower() or "agree" in reply.lower() else -0.05)
    new_lev = max(0.1, min(0.9, new_lev))

    session_data = {
        "scenario": request.scenario,
        "history": [{"role": m.role, "content": m.content} for m in request.history],
        "leverage": new_lev,
        "timestamp": datetime.now(UTC)
    }

    if request.session_id:
        await sessions_collection.update_one({"_id": ObjectId(request.session_id)}, {"$set": session_data})
        sid = request.session_id
    else:
        res = await sessions_collection.insert_one(session_data)
        sid = str(res.inserted_id)

    return NegotiationResponse(opponent_reply=reply, coach_tip=tip, new_leverage=new_lev, new_mood="neutral", session_id=sid)

# ✅ FIXED: Now returns "count" to prevent Swift crashing
@app.get("/sessions")
async def list_sessions(limit: int = 10):
    """List recent negotiation sessions"""
    sessions = await sessions_collection.find().sort("timestamp", -1).limit(limit).to_list(length=limit)
    
    for session in sessions:
        session["_id"] = str(session["_id"])
    
    return {
        "sessions": sessions, 
        "count": len(sessions) # <--- Swift needs this!
    }

@app.get("/analyze/{session_id}")
async def analyze_session(session_id: str):
    try:
        session = await sessions_collection.find_one({"_id": ObjectId(session_id)})
    except:
        raise HTTPException(400, "Invalid ID")
    
    if not session: raise HTTPException(404, "Session not found")

    # Return cached analysis if exists
    if "analysis" in session:
        return session["analysis"]

    # Generate new analysis
    history_text = "\n".join([f"{m['role']}: {m['content']}" for m in session.get('history', [])])
    analysis = generate_analysis(history_text, session.get('scenario', 'Unknown'))
    
    # Save to DB
    await sessions_collection.update_one({"_id": ObjectId(session_id)}, {"$set": {"analysis": analysis}})
    
    return analysis

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)