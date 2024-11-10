//
//  OpenAIManager.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import Foundation
import OpenAI

struct OpenAIManager {
    
    private let openAI: OpenAI
    
    init() {
        let openAIKey: String = {
            if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
               let plistData = FileManager.default.contents(atPath: path),
               let config = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] {
                return config["OpenAI_API_Key"] as? String ?? ""
            }
            return ""
        }()
        self.openAI = OpenAI(apiToken: openAIKey)
    }
    
    /// Function to send a message as a prompt and get a response
    func sendMessage(_ message: String) async -> String? {
        let query = ChatQuery(
            messages: [.init(role: .user, content: message)!],
            model: .gpt3_5Turbo
        )
        
        do {
            let result = try await openAI.chats(query: query)
            if let responseContent = result.choices.first?.message.content {
                print("Response: \(responseContent)")
                return responseContent.string
            } else {
                print("No response content available.")
                return nil
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
