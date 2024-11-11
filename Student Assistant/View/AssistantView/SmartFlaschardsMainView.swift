//
//  SmartFlaschardsMainView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import SwiftUI

struct SmartFlaschardsMainView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @State var content: String = ""
    @State var showAddRectangle: Bool = false
    
    var body: some View {
        VStack {
            if showAddRectangle {
                
            } else {
                HStack {
                    Button {
                        appCoordinator.presentCustomSheet(
                            VStack {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 20) {
                                        Text("Enter flashcards description... ")
                                            .foregroundColor(.gray)
                                            .padding(.top, 10)
                                            .padding(.horizontal, 18)
                                            .opacity(content.isEmpty ? 1 : 0)
                                        
                                            TextEditor(text: $content)
                                                .autocorrectionDisabled()
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 300)
                                                .background(Color(.systemGray6))
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .shadow(radius: 2)
                                                .padding(.horizontal)
                                        
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
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                }
                                .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
                            }
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
                        )
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.appJordyBlue)
                            .frame(width: 150, height: 100)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    .foregroundColor(.appJordyBlue)
                            )
                            .shadow(radius: 2)
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    SmartFlaschardsMainView()
}
