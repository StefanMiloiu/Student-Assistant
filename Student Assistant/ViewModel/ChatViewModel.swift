//
//  ChatViewModel.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var flashcards: [Flashcard]? = nil
    @Published var recomandations: String? = nil
    private let openAIManager = OpenAIManager()
    
    func sendMessage(_ message: String) {
        let userMessage = ChatMessage(id: UUID(), content: message, isUser: true)
        messages.append(userMessage)
        
        // Construct conversation history from recent messages
        let recentMessages = messages // Take the last 5 messages, you can adjust this number as needed
        let conversationHistory = recentMessages.map { msg in
            "\(msg.isUser ? "User" : "Assistant"): \(msg.content)"
        }.joined(separator: "\n")
        
        // Get the summary of assignments and exams
        let dataSummary = openAIManager.fetchDataForAssignmentsAndExams()
        
        // Create the full prompt with conversation history and data summary
        let prompt = """
                Here is my schedule information:
                \(dataSummary)
                
                Conversation history:
                \(conversationHistory)
                
                User: \(message)
                Assistant:
                """
        
        Task {
            if let response = await openAIManager.sendMessage(prompt) {
                let aiMessage = ChatMessage(id: UUID(), content: response, isUser: false)
                await MainActor.run {
                    messages.append(aiMessage)
                }
            } else {
                await MainActor.run {
                    messages.append(ChatMessage(id: UUID(), content: "Failed to get a response.", isUser: false))
                }
            }
        }
    }
    
    func generateFlashcards(_ content: String) async {
        DispatchQueue.main.async {
            self.flashcards = nil
        }
        if let flashcards = await openAIManager.generateStudyCards(from: content) {
            await MainActor.run {
                self.flashcards = flashcards
            }
        }
    }
    
    func getStudyRecommendations() async {
        Task {
            if let response = await openAIManager.getStudyRecomandations(){
                await MainActor.run {
                    self.recomandations = response
                }
            }
        }
    }
    
    func clearMessages() {
        messages.removeAll()
    }
    
    
}

struct ChatMessage: Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
}
