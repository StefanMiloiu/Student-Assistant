//
//  FlashCardView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import SwiftUI

struct FlashCardView: View {
    let flashcard: Flashcard
    @Binding var showAnswer: Bool
    
    var body: some View {
        VStack {
            Text(flashcard.question)
                .padding()
                .frame(height: 200)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
                .padding(.horizontal)
                .padding(.top)
            if showAnswer {
                Text(flashcard.answer)
                    .padding()
                    .frame(height: 200)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .background(Color.appJordyBlue.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .padding(.top, -14)
                    .transition(.slide)
            }
            
        }
    }
}

#Preview {
    FlashCardView(flashcard: Flashcard(question: "De cine este dezvoltat limbajul de programare swift?", answer: "De catre compania 'Apple'"), showAnswer: .constant(false))
}
