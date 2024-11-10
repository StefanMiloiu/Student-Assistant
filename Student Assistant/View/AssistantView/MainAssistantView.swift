//
//  MainAssistantView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//
import SwiftUI

struct MainAssistantView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // 2x2 Grid of buttons
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        AssistantButton(label: "Chat", systemImage: "paperplane")
                            .padding(.leading)
                        AssistantButton(label: "Smart Flashcards", systemImage: "menucard")
                            .padding(.trailing)
                    }
                    
                    HStack(spacing: 20) {
                        AssistantButton(label: "Exams", systemImage: "calendar")
                            .padding(.leading)
                        AssistantButton(label: "Assignments", systemImage: "checkmark.circle")
                            .padding(.trailing)
                    }
                }
                Spacer()
            }
            .navigationTitle("Smart Assistant")
        }
    }
}

// Custom view for each button with styling
struct AssistantButton: View {
    let label: String
    let systemImage: String
    
    var body: some View {
        Button(action: {
            print("\(label) tapped")
        }) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 30))
                    .foregroundColor(.appJordyBlue)
                Text(label)
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

#Preview {
    MainAssistantView()
}
