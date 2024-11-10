//
//  SmartFlaschardsMainView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import SwiftUI

struct SmartFlaschardsMainView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    @State var content: String = ""
    @State var showAddRectangle: Bool = false
    var body: some View {
        VStack {
            if showAddRectangle {
                TextField("Tell us about your flashcards, we'll make them smart!", text: $content)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10).inset(by: 10))
                    .shadow(radius: 2)
                    .padding()
                    .onSubmit {
                        appCoordinator.pushCustom(SmartFlashcardsView(content: content))
                    }
            } else {
                HStack {
                    Button {
                        showAddRectangle.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.appJordyBlue)
                            .frame(width: 100, height: 100)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10).inset(by: 10))
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
