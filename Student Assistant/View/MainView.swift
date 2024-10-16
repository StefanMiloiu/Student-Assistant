//
//  MainView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct MainView: View {
    
    @State var selectedTimer: Bool = false
    
    // MARK: - Top part with (Assignments, ...)
    var assignmentNavigationView: some View {
        NavigationLink(destination: AssignmentListView()) {
            CustomAssignmentIcon()
        }
    }
    
    var examNavigationView: some View {
        NavigationLink(destination: ExamsCalendarView()) {
            CustomExamIcon()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image
                Image("BackgroundImage")
                    .resizable()
                    .scaleEffect(1.2)
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
                    .padding(.top, 50)
                    .blur(radius: 5)
                
                VStack {
                    HStack(spacing: 40) {
                        assignmentNavigationView
                            .tint(.red)
                        
                        examNavigationView
                            .tint(.lightBlue)
                    }
                    .padding(.top)
                    .toolbar {
                        // Customizing the navigation title appearance
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Home")
                                .font(.system(size: 28, weight: .bold))
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    
                    Spacer()
                    
                    // Wrap the trackNavigationView in a ZStack
                    ZStack {
                        if !selectedTimer {
                            Button(action: {                            selectedTimer.toggle()
                            }){
                                CustomTrackTimeIcon()
                                    .transition(.opacity) // Use opacity transition
                            }
                        } else {
                            MainTrackTimeView()
                                .transition(.opacity) // Use opacity transition
                        }
                    }
                    .animation(.easeInOut(duration: 0.5), value: selectedTimer) // Apply animation
                    
                    Button(action: {
                        withAnimation {
                            selectedTimer.toggle()
                        }
                    }) {
                        if selectedTimer == true {
                            HStack {
                                Text("Back ")
                                Image(systemName: "arrowshape.turn.up.backward")
                            }
                            .foregroundStyle(.white)
                            .font(.headline)
                            .padding()
                            .background(Color.gray.opacity(0.6))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 115)
                    
                    Spacer()
                }
            }
        }
        .tint(.red) // Tint for the entire NavigationStack
    }
}

#Preview {
    MainView()
}
