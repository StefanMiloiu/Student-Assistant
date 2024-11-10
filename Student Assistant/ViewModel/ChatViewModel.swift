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
    private let openAIManager = OpenAIManager()
    
    func sendMessage(_ message: String) {
        let userMessage = ChatMessage(id: UUID(), content: message, isUser: true)
        messages.append(userMessage)
        
        // Get the summary of assignments and exams
        let dataSummary = openAIManager.fetchDataForAssignmentsAndExams()
        
        // Create the full prompt with data summary
        let prompt = """
            Here is my schedule information:
            \(dataSummary)
            
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
    
    func generateFlashcards(_ content: String) -> [Flashcard]? {
        Task {
            if let flashcards = await openAIManager.generateStudyCards(from: content) {
                await MainActor.run {
                    self.flashcards = flashcards
                }
            }
        }
        return self.flashcards
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
