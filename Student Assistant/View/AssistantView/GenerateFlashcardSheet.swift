//
//  GenerateFlashcardSheet.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 16.11.2024.
//

import SwiftUI

struct GenerateFlashcardSheet: View {
    
    @Binding var content: String
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .autocorrectionDisabled()
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    if content.isEmpty {
                        Text("Enter flashcards description...")
                            .foregroundColor(Color.gray)
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 25)
                Button {
                    appCoordinator.dismissSheet()
                    appCoordinator.pushCustom(
                        SmartFlashcardsView(content: content)
                    )
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}
