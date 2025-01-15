//
//  SmartInteractiveFlashcardsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.01.2025.
//

import SwiftUI

struct SmartInteractiveFlashcardsView: View {
    
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var currentIndex: Int = 0
    @State private var selectedAnswer: String? = nil
    @State private var isCorrectAnswer: Bool? = nil
    @State private var showNextButton: Bool = false
    var progress: Double {
        if let flashcards = viewModel.interactiveFlashcards, !flashcards.isEmpty {
            return Double(currentIndex + 1) / Double(flashcards.count)
        }
        return 0.0
    }
    let content: String
    
    var body: some View {
        VStack {
            if let flashcards = viewModel.interactiveFlashcards, !flashcards.isEmpty {
                ProgressView(value: progress) {
                    Text("Progress")
                } currentValueLabel: {
                    Text("\(currentIndex + 1) of \(viewModel.interactiveFlashcards!.count)")
                }
                .padding()

                VStack {
                    // Display the current question
                    Text(flashcards[currentIndex].question)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .padding(.bottom, 20)
                    
                    Text("Select the correct answer:")
                        .font(.subheadline)
                        .padding(.top, 10)
                    
                    // Display the three answer choices
                    ForEach([flashcards[currentIndex].answerOne, flashcards[currentIndex].answerTwo, flashcards[currentIndex].answerThree].shuffled(), id: \.self) { answer in
                        Button(action: {
                            selectedAnswer = answer
                            isCorrectAnswer = (answer == flashcards[currentIndex].answerOne)
                            showNextButton = true
                        }) {
                            Text(answer)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedAnswer == answer ? (isCorrectAnswer == true ? Color.green : Color.red) : Color.appJordyBlue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // "Next" or "Finish" button
                    if showNextButton {
                        Button(action: {
                            withAnimation {
                                if isCorrectAnswer == true, currentIndex < flashcards.count - 1 {
                                    currentIndex += 1
                                    resetQuestion()
                                } else if currentIndex == flashcards.count - 1 {
                                    // Optionally handle finish
                                    print("Flashcards completed!")
                                }
                                selectedAnswer = nil
                                isCorrectAnswer = nil
                                showNextButton = false
                            }
                        }) {
                            Text(currentIndex == flashcards.count - 1 ? "Finish" : "Next Question")
                                .font(.headline)
                                .frame(height: 50)
                                .padding(.horizontal)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.top)
                    }
                }
                .padding()
            } else {
                VStack {
                    ProgressView()
                        .frame(width: 100, height: 100, alignment: .center)
                    Text("Generating flashcards...")
                        .font(.headline)
                    Text("Your interactive flashcards about \(content) will be ready soon!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.generateInteractiveFlashcards(content)
                resetQuestion()
            }
        }
    }
    
    private func resetQuestion() {
        selectedAnswer = nil
        isCorrectAnswer = nil
        showNextButton = false
    }
}

#Preview {
    SmartInteractiveFlashcardsView(content: "In limba romana te rog sa imi faci flashcarduri interactive despre istoria romaniei")
        .environmentObject(ChatViewModel())
}
