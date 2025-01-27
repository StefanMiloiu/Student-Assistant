//
//  SmartInteractiveFlashcardsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.01.2025.
//

import SwiftUI

struct SmartInteractiveFlashcardsView: View {
    
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var selectedAnswer: String? = nil
    @State private var isCorrectAnswer: Bool? = nil
    @State private var showNextButton: Bool = false
    @State private var list: [String] = []
    @State var showTimeoutAlert: Bool = false
    @State var didTimeout: Bool = false
    let nrOfFlashcards: Int
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
                VStack {
                    // Display the current question
                    Text(flashcards[currentIndex].question)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                        .padding(.bottom, 20)
                    
                    ProgressView(value: progress) {
                        Text("Progress")
                    } currentValueLabel: {
                        Text("\(currentIndex + 1) of \(viewModel.interactiveFlashcards!.count)")
                    }
                    .padding()
                    
                    Text("Select the correct answer:")
                        .font(.subheadline)
                        .padding(.top, 10)
                    
                    // Display the three answer choices
                    ForEach(list, id: \.self) { answer in
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
                            if currentIndex == flashcards.count - 1 {
                                withAnimation {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
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
                .onChange(of: currentIndex) {
                    if let flashcards = viewModel.interactiveFlashcards, !flashcards.isEmpty {
                        list = [flashcards[currentIndex].answerOne,
                                flashcards[currentIndex].answerTwo,
                                flashcards[currentIndex].answerThree].shuffled()
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
                .alert(isPresented: $showTimeoutAlert) {
                    Alert(
                        title: Text("Timeout"),
                        message: Text("Flashcards could not be generated in time. Please try again."),
                        dismissButton: .default(Text("OK")) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.generateInteractiveFlashcards(content, nrOfCards: nrOfFlashcards)
                resetQuestion()
                // Cancel timeout if flashcards are generated
                if viewModel.flashcards != nil, !viewModel.flashcards!.isEmpty {
                    didTimeout = false
                }
                if let flashcards = viewModel.interactiveFlashcards, !flashcards.isEmpty {
                    list = [flashcards[currentIndex].answerOne,
                            flashcards[currentIndex].answerTwo,
                            flashcards[currentIndex].answerThree].shuffled()
                }
            }
            
            // Set a 5-second timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                if viewModel.flashcards == nil || viewModel.flashcards!.isEmpty {
                    didTimeout = true
                    showTimeoutAlert = true
                }
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
    SmartInteractiveFlashcardsView(nrOfFlashcards: 5, content: "In limba romana te rog sa imi faci flashcarduri interactive despre istoria romaniei")
        .environmentObject(ChatViewModel())
}
