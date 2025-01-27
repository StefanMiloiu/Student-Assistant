//
//  SmartFlashcardsView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import SwiftUI

struct SmartFlashcardsView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var showAnswer: Bool = false
    @State var currentIndex = 0
    @State var showTimeoutAlert: Bool = false
    @State var didTimeout: Bool = false
    let nrOfFlashcards: Int
    let content: String
    var progress: Double {
        if let flashcards = viewModel.flashcards, !flashcards.isEmpty {
            return Double(currentIndex + 1) / Double(flashcards.count)
        }
        return 0.0
    }
    
    var body: some View {
        VStack {
            if viewModel.flashcards != nil,
               viewModel.flashcards!.count > 0 {
                HStack {
                    Button(action: {
                        Task {
                            let contentHarder = content + "And make them more difficult"
                            viewModel.flashcards!.removeAll()
                            currentIndex = 0

                            await viewModel.generateFlashcards(contentHarder, nrOfCards: nrOfFlashcards)
                            if viewModel.flashcards != nil, !viewModel.flashcards!.isEmpty {
                                didTimeout = false
                            }
                            // Set a 5-second timeout
                            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                                if (viewModel.flashcards == nil ||
                                    viewModel.flashcards!.isEmpty) &&
                                    currentIndex == 0 {
                                    didTimeout = true
                                    showTimeoutAlert = true
                                }
                            }
                        }
                    }){
                        Text("Generate Harder")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 2)
                            .padding()
                    }
                }
                ProgressView(value: progress) {
                    Text("Progress")
                } currentValueLabel: {
                    Text("\(currentIndex + 1) of \(viewModel.flashcards!.count)")
                }
                .padding()
                FlashCardView(flashcard: viewModel.flashcards![currentIndex], showAnswer: $showAnswer)
                HStack {
                    Button(action: {
                        withAnimation {
                            if currentIndex > 0 {
                                currentIndex -= 1
                                showAnswer = false
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
                                showAnswer = false
                            } else if viewModel.flashcards!.count - 1 == currentIndex {
                                viewModel.flashcards!.removeAll()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        Text(viewModel.flashcards!.count - 1 > currentIndex ? "Next" : "Finish")
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
                // Start generating flashcards
                await viewModel.generateFlashcards(content, nrOfCards: nrOfFlashcards)
                
                // Cancel timeout if flashcards are generated
                if viewModel.flashcards != nil, !viewModel.flashcards!.isEmpty {
                    didTimeout = false
                }
            }
            
            // Set a 15-second timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                if viewModel.flashcards == nil || viewModel.flashcards!.isEmpty {
                    didTimeout = true
                    showTimeoutAlert = true
                }
            }
        }
        .onDisappear {
            if viewModel.flashcards != nil,
               viewModel.flashcards!.count > 0 {
                viewModel.flashcards!.removeAll()
            }
        }
    }
}

#Preview {
    SmartFlashcardsView(nrOfFlashcards: 5, content: "In limba romana te rog sa imi faci flashcarduri despre istoria romaniei, 5 flashcarduri te rog sa imi faci")
        .environmentObject(ChatViewModel())
}
