//
//  ChatAssistantView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import SwiftUI

struct ChatAssistantView: View {
    @EnvironmentObject private var viewModel: ChatViewModel
    @State private var userMessage: String = ""
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        VStack {
            if viewModel.messages.isEmpty {
                ContentUnavailableView("What's up?", systemImage: "ellipsis.message", description: Text("Ask me anything!\n I will try my best to help you..."))
            } else {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.messages, id: \.id) { message in
                                HStack {
                                    if message.isUser {
                                        Spacer()
                                        Text(message.content)
                                            .padding()
                                            .background(Color.blue.opacity(0.7))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .frame(maxWidth: 250, alignment: .trailing)
                                    } else {
                                        Text(message.content)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.primary)
                                            .cornerRadius(10)
                                            .frame(maxWidth: 250, alignment: .leading)
                                        Spacer()
                                    }
                                }
                                .id(message.id)
                            }
                        }
                        .padding()
                        .onChange(of: viewModel.messages.count) {
                            // Autoscroll to the last message
                            if let lastMessage = viewModel.messages.last {
                                withAnimation {
                                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        hideKeyboard()
                    } // Dismisses the keyboard on scroll/tap
                }
            }
            HStack {
                TextField("Type your message...", text: $userMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocorrectionDisabled()
                    .padding(.leading, 5)
                
                Button(action: {
                    viewModel.sendMessage(userMessage)
                    userMessage = ""
                }) {
                    Text("Send")
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(userMessage.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat Assistant")
        .tint(.primary)
    }
}

#Preview {
    ChatAssistantView()
}
