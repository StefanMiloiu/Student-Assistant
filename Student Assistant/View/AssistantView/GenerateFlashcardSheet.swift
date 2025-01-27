//
//  GenerateFlashcardSheet.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 16.11.2024.
//

import SwiftUI

struct GenerateFlashcardSheet: View {
    
    var isInteractive: Bool = false
    @Binding var content: String
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @State var selectedNrOfFlashcards: Int = 5
    
    
    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .autocorrectionDisabled()
                        .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 300)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue.opacity(0.7), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)

                    if content.isEmpty {
                        Text("Enter flashcards description...")
                            .foregroundColor(Color.gray)
                            .padding(.horizontal, 24) // Match padding to align correctly
                            .padding(.vertical, 11) // Adjust top padding to match text entry
                    }
                }
                .padding(.top, 30)
                HStack {
                    Text("Number of flashcards to create")
                    Picker("Select Number", selection: $selectedNrOfFlashcards) {
                        ForEach(5...12, id: \.self) { i in
                            Text(String(i)) // Convert Int to String
                                .tag(i)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Button {
                    appCoordinator.dismissSheet()
                    if isInteractive {
                        appCoordinator.pushCustom(
                            SmartInteractiveFlashcardsView(nrOfFlashcards: selectedNrOfFlashcards, content: content)
                        )
                    } else {
                        appCoordinator.pushCustom(
                            SmartFlashcardsView(nrOfFlashcards: selectedNrOfFlashcards, content: content)
                        )
                    }
                    content = ""
                } label: {
                    Text("Generate")
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color(.appJordyBlue))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                }
                .padding(.top, 25)
                
                Text("Please make the flashcard description concise and clear. The longer the question the better it will be able to help you learn.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    GenerateFlashcardSheet(isInteractive: false, content: .constant(""))
}
