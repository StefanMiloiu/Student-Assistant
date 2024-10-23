//
//  StopwatchView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 19.10.2024.
//

import SwiftUI

struct StopwatchView: View {
    
    @ObservedObject var vm = TrackTimeListViewModel()
    @State var time: String = ""
    @State var subject: String = ""
    @State var noteText: String = ""
    @State var showCustomAlert = false
    @State var showCancel = false
    @State private var timer: Timer? // Timer to update the time
    @State var note: Bool = false
    @FocusState var focus: Focus?
    
    var body: some View {
        VStack {
            ZStack {
                
                Circle()
                    .fill(LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 170, height: 170)
                    .blur(radius: 2)
                
                // Dashed Circular Border
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .frame(width: 170, height: 170)
                    .foregroundColor(.orange)
                
                Text(time)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(width: 150, height: 50)
                    .background(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(width: 150, height: 50)
            }
            .padding(.bottom, 30)
            
            HStack(spacing: 25) {
                Button(action: {
                    showCustomAlert.toggle()
                }) {
                    Text("Start")
                        .frame(width: 100, height: 50)
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showCancel.toggle()
                }) {
                    Text("Stop")
                        .frame(width: 100, height: 50)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
            }
        }
        .overlay(
            ZStack {
                if showCustomAlert {
                    VStack(spacing: 20) {
                        Text("What are you learning?")
                            .font(.headline)
                            .foregroundStyle(.black)
                        
                        TextField("Subject", text: $subject)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(5)
                            .autocorrectionDisabled()
                            .focused($focus, equals: .subject)
                        
                        
                        HStack(spacing: 50) {
                            Button("Start") {
                                if subject != "" {
                                    let succes = vm.startTimeTrack(startDate: Date(), subject: subject)
                                    if succes {
                                        startTimer()
                                    }
                                    showCustomAlert = false // Close the alert
                                }
                            }
                            .frame(width: 100, height: 50)
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(10)
                            
                            Button("Cancel") {
                                showCustomAlert = false // Close the alert
                            }
                            .frame(width: 100, height: 50)
                            .background(Color.gray)
                            .cornerRadius(10)
                        }
                    }
                    .frame(width: 350, height: 275, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .onAppear {
                        self.focus = .subject
                        
                    }
                }
                if showCancel {
                    VStack(spacing: 20) {
                        Section {
                            Toggle("Add a note?", isOn: $note)
                                .foregroundStyle(.gray.opacity(0.7))
                                .frame(width: 250)
                                .padding(.bottom, 30)
                        }
                        if note {
                            TextField("Notes", text: $noteText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(5)
                                .autocorrectionDisabled()
                        }
                        
                        
                        HStack(spacing: 50) {
                            Button("Save") {
                                if noteText != "" {
                                    vm.stopTimeTrack(endDate: Date(), notes: noteText)
                                    showCancel = false
                                }
                            }
                            .frame(width: 100, height: 50)
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(10)
                            
                            Button("Don't save") {
                                vm.deleteStartedSession()
                                showCancel = false
                            }
                            .frame(width: 100, height: 50)
                            .background(Color.gray)
                            .cornerRadius(10)
                        }
                    }
                    .frame(width: 350, height: 275, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
                
        )
        .onAppear {
            self.time = "00:00:00"
            if let time = vm.fetchStopWatchTimes() {
                self.time = time
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    // Update the time variable with the current stopwatch time
                    self.time = vm.fetchStopWatchTimes() ?? "00:00:00"
                }
            }
        }
    }
    
    private func startTimer() {
        // Invalidate the previous timer if it's already running
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update the time variable with the current stopwatch time
            time = vm.fetchStopWatchTimes() ?? "00:00:00"
        }
    }
    
    // Function to stop the timer
    private func stopTimer() {
        timer?.invalidate() // Stop the timer
        timer = nil
    }
}

#Preview {
    StopwatchView()
}
