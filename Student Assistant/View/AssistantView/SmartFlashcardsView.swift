//
//  SmartFlashcardsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import SwiftUI

struct SmartFlashcardsView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State var showAnswer: Bool = false
    @State var currentIndex = 0
    let content: String
    
    var body: some View {
        VStack {
            if viewModel.flashcards != nil,
               viewModel.flashcards!.count > 0 {
                FlashCardView(flashcard: viewModel.flashcards![currentIndex], showAnswer: $showAnswer)
                HStack {
                    Button(action: {
                        withAnimation {
                            if currentIndex > 0 {
                                currentIndex -= 1
                            }
                        }
                    }) {
                        Text("Back")
                            .font(.headline)
                            .frame(height: 50)
                            .padding(.horizontal)
                            .background(Color.appJordyBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                            .padding(.leading)
                    }
                    Button(action: {
                        withAnimation {
                            showAnswer.toggle()
                        }
                    }) {
                        Text("\(showAnswer == true ? "Hide answer" : "Show answer")")
                            .font(.headline)
                            .frame(height: 50)
                            .padding(.horizontal)
                            .background(Color.appJordyBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                    }
                    Button(action: {
                        withAnimation {
                            if viewModel.flashcards!.count - 1 > currentIndex {
                                currentIndex += 1
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .frame(height: 50)
                            .padding(.horizontal)
                            .background(Color.appJordyBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                            .padding(.trailing)
                    }
                }
            } else {
                VStack {
                    ProgressView()
                        .frame(width: 100, height: 100, alignment: .center)
                    Text("Generating flashcards...")
                        .font(.headline)
                    Text("Your flashcards about \(content) will be ready soon!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.generateFlashcards(content)
            }
        }
    }
}

#Preview {
    SmartFlashcardsView(content: "In limba romana te rog sa imi faci flashcarduri despre istoria romaniei, 5 flashcarduri te rog sa imi faci")
}
