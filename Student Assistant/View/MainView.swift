//
//  MainView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct MainView: View {
    
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
                    .blur(radius: 0)
                VStack{
                    HStack(spacing: 40) {
                        assignmentNavigationView
                            .tint(.red)  // Ensure the tint color is set
                        
                        examNavigationView
                            .tint(.lightBlue)
                    }
                    .padding(.top)
                    .toolbar {
                        // Customizing the navigation title appearance
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Home")
                                .font(.system(size: 28, weight: .bold)) // Change the size and weight as needed
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    
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
