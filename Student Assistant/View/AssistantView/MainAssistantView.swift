//
//  MainAssistantView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//
import SwiftUI

struct MainAssistantView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 2x2 Grid of buttons
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        AssistantButton(label: SmartAssistanCases.chat, systemImage: "paperplane")
                            .padding(.leading)
                        AssistantButton(label: SmartAssistanCases.smartFlashcard, systemImage: "menucard")
                            .padding(.trailing)
                    }
                    
                    HStack(spacing: 20) {
                        AssistantButton(label: SmartAssistanCases.exams, systemImage: "calendar")
                            .padding(.leading)
                        AssistantButton(label: SmartAssistanCases.assignments, systemImage: "checkmark.circle")
                            .padding(.trailing)
                    }
                }
                .padding(.bottom, 30)
                
                if viewModel.recomandations != nil  && !viewModel.recomandations!.isEmpty  {
                    ScrollView {
                        Text(viewModel.recomandations!)
                    }
                    .font(.title3)
                    .padding(.horizontal)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(.appJordyBlue.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                }
                Spacer()
            }
            .navigationTitle("Smart Assistant")
            .tint(.primary)
        }
    }
}

// Custom view for each button with styling
struct AssistantButton: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    let label: SmartAssistanCases
    let systemImage: String
    
    var body: some View {
        VStack {
            Button(action: {
                switch label {
                case .chat:
                    appCoordinator.pushCustom(ChatAssistantView())
                case .smartFlashcard:
                    appCoordinator.pushCustom(SmartFlaschardsMainView())
                case .exams:
                    appCoordinator.pushCustom(ChatAssistantView())
                case .assignments:
                    appCoordinator.pushCustom(ChatAssistantView())
                }
            }) {
                VStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 30))
                        .foregroundColor(.appJordyBlue)
                    Text(label.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
            }
        }
    }
}

enum SmartAssistanCases: String {
    case chat = "Chat"
    case smartFlashcard = "Smart Flashcard"
    case exams = "Exams"
    case assignments = "Assignments"
}

#Preview {
    MainAssistantView()
}
