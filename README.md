# Negotium

**AI-Powered Negotiation Training Simulator**

Negotium is an iOS application designed to help professionals master negotiation skills through realistic AI-powered simulations. Users can practice salary negotiations, business deals, contract discussions, and more with an adaptive AI opponent while receiving real-time coaching and comprehensive post-session analytics.

---

## Features

### Multi-Agent AI System
- **Opponent Agent** - Adaptive AI negotiator that responds dynamically to user tone and tactics
- **Shadow Coach Agent** - Provides real-time tactical recommendations during negotiations
- **Post-Session Analyst** - Delivers in-depth performance analysis with actionable insights

### iOS Application (SwiftUI)
- Modern dark-themed interface with glass morphism design elements
- Interactive negotiation chat interface
- Real-time leverage and patience indicators
- Session history and progress tracking
- Comprehensive post-negotiation analysis with data visualization

### Backend Service (FastAPI + Python)
- RESTful API architecture for AI interactions
- MongoDB integration for session persistence
- Multi-provider AI support (Groq, OpenAI)
- Optional local model deployment for offline capability

---

## Architecture

```
Negotium/
├── Negotium/                    # iOS App (SwiftUI)
│   ├── NegotiumApp.swift        # App entry point
│   ├── Core/
│   │   ├── Models.swift         # Data models
│   │   ├── NetworkManager.swift # API client
│   │   ├── Theme.swift          # Design system
│   │   └── Components.swift     # Reusable UI components
│   └── Views/
│       ├── ContentView.swift    # Main navigation
│       ├── LandingView.swift    # Onboarding/login
│       ├── DashboardView.swift  # Command center
│       ├── ScenariosView.swift  # Scenario selection
│       ├── NegotiationView.swift# Main simulation
│       ├── AnalysisView.swift   # Post-session analysis
│       └── LearnSkillView.swift # Skill learning modules
│
└── backend/                     # Python API Server
    └── main.py                  # FastAPI application
```

---

## Getting Started

### Prerequisites
- **iOS Development**: Xcode 15 or later, iOS 17+
- **Backend**: Python 3.10+, MongoDB instance

### Backend Setup

1. **Navigate to backend folder**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install fastapi uvicorn openai python-dotenv motor pymongo certifi pydantic
   ```

4. **Create `.env` file**
   ```env
   # Choose one AI provider:
   GROQ_API_KEY=gsk_your_groq_key_here
   # OR
   OPENAI_API_KEY=sk-your_openai_key_here

   # MongoDB Connection
   MONGODB_URL=mongodb+srv://user:password@cluster.mongodb.net/

   # Optional: Enable local model
   USE_LOCAL_MODEL=false
   ```

5. **Run the server**
   ```bash
   python main.py
   ```
   Server runs at `http://localhost:8000`

### iOS App Setup

1. Open `Negotium.xcodeproj` in Xcode
2. Ensure the backend is running on `localhost:8000`
3. Build and run on simulator or device

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/negotiate` | Send message, get AI response + coach tip |
| `GET` | `/sessions` | List recent negotiation sessions |
| `GET` | `/analyze/{session_id}` | Get detailed analysis for a session |

### Example: Negotiate Request
```json
POST /negotiate
{
  "scenario": "Salary Negotiation",
  "history": [
    {"role": "user", "content": "I'd like to discuss my compensation."}
  ],
  "current_leverage": 0.5,
  "session_id": null
}
```

### Example: Response
```json
{
  "opponent_reply": "I understand. What salary range are you looking at?",
  "coach_tip": "Anchor high - state a specific number first.",
  "new_leverage": 0.55,
  "new_mood": "neutral",
  "session_id": "65a1b2c3d4e5f6g7h8i9j0k1"
}
```

---

## AI Models

| Provider | Main Model (Opponent/Analyst) | Coach Model |
|----------|-------------------------------|-------------|
| Groq | `llama-3.3-70b-versatile` | `llama-3.1-8b-instant` |
| OpenAI | `gpt-4-turbo` | `gpt-3.5-turbo` |

---

## Design System

The app uses a custom dark theme with:
- **Background**: `#0D0D0D`
- **Teal Accent**: `#00D9C4`
- **Purple Accent**: `#A855F7`
- **Amber Accent**: `#F59E0B`

UI components feature glass morphism effects with `.ultraThinMaterial` backgrounds.

---

## Negotiation Analysis

After each session, the AI analyzes your transcript and provides:
- **Summary** - Overall performance assessment
- **Outcome** - Success or Failure determination
- **Strengths** - What you did well
- **Mistakes** - Areas for improvement
- **Skill Gaps** - Specific skills to practice (e.g., Anchoring, Active Listening)

---

## Roadmap

- [ ] User authentication and account management
- [ ] Expanded negotiation scenario library
- [ ] Multiplayer mode for peer-to-peer negotiations
- [ ] Voice input and speech recognition
- [ ] Offline mode with local AI model support
- [ ] Skill progression and certification system
- [ ] Performance leaderboards and benchmarking

---

## License

This project is proprietary. All rights reserved.

---

## Contact

For inquiries, please contact the Negotium development team.
