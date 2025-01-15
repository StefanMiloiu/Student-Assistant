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
                    Text("Generate \nFlashcards")
                        .foregroundStyle(.appJordyBlue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                    
                    Button {
                        appCoordinator.presentCustomSheet(
                            GenerateFlashcardSheet(content: $content)
                        )
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.appJordyBlue)
                            .frame(width: 180, height: 120)
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
                }
                .padding(.bottom, 35)
                
            }
            
            Image("Owl")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 25)
            
            Text("To get help by our smart assistant please click the button that the owl indicates to. Also please be specific if you want the best results.")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .padding()
            
            
        }
        .navigationTitle("Smart Flaschards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SmartFlaschardsMainView()
}
