
import SwiftUI

// FIXED: Moved struct here to ensure visibility
struct LearningResource: Identifiable {
    let id = UUID()
    let title: String
    let type: String
    let duration: String
    let icon: String
}

struct LearnSkillView: View {
    let skillName: String
    @Environment(\.dismiss) var dismiss
    
    var resources: [LearningResource] {
        if skillName.contains("AWS") {
            return [
                LearningResource(title: "AWS Cloud Practitioner Essentials", type: "Course", duration: "6h 30m", icon: "cloud.fill"),
                LearningResource(title: "IAM Roles & Policies Deep Dive", type: "Video", duration: "45m", icon: "lock.shield.fill"),
                LearningResource(title: "Serverless Architecture Guide", type: "Article", duration: "15m", icon: "doc.text.fill")
            ]
        } else {
            return [
                LearningResource(title: "Next.js 14 Full Course", type: "Course", duration: "4h 15m", icon: "play.laptopcomputer"),
                LearningResource(title: "Server Actions & Mutations", type: "Video", duration: "25m", icon: "bolt.fill"),
                LearningResource(title: "Optimizing Fonts & Images", type: "Article", duration: "10m", icon: "photo.fill")
            ]
        }
    }
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // Header
                    VStack(spacing: 20) {
                        ZStack {
                            Circle().fill(Theme.purple.opacity(0.1)).frame(width: 100, height: 100)
                            Image(systemName: "book.and.wrench.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Theme.purple)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Master \(skillName)")
                                .font(.title).bold()
                                .foregroundStyle(.white)
                            
                            Text("Curated resources to bridge your knowledge gap.")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 40)
                    
                    // List
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Learning Path")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.leading, 4)
                        
                        ForEach(resources) { resource in
                            HStack(spacing: 16) {
                                Image(systemName: resource.icon)
                                    .font(.title3)
                                    .foregroundStyle(Theme.teal)
                                    .frame(width: 48, height: 48)
                                    .background(Theme.teal.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(resource.title)
                                        .font(.subheadline).bold()
                                        .foregroundStyle(.white)
                                    
                                    HStack {
                                        Text(resource.type)
                                            .font(.caption2).bold()
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.white.opacity(0.1))
                                            .cornerRadius(4)
                                            .foregroundStyle(.white.opacity(0.8))
                                        
                                        Text("• \(resource.duration)")
                                            .font(.caption2)
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(16)
                            .glass()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Return to Analysis")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.teal, lineWidth: 1))
                            .foregroundStyle(Theme.teal)
                    }
                    .padding(.bottom, 20)
                }
                .padding(24)
            }
        }
    }
}
