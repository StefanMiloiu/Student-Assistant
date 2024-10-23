//
//  CustomTrackTimeIcon.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//

import SwiftUI

struct CustomTrackTimeIcon: View {
    
    @ObservedObject var vm = TrackTimeListViewModel()
    @State var time: String?
    @State var timer: Timer?
    var body: some View {
        ZStack {
            // Circular Background with Gradient
            Circle()
                .fill(LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing))
                .frame(width: 150, height: 150)
                .blur(radius: 2)
            
            // Dashed Circular Border
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                .frame(width: 150, height: 150)
                .foregroundColor(.orange)
            
            // Content
            if time != nil {
                VStack {
                    Image(systemName: "timer.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    
                    Text(time!)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(width: 100, height: 50)
                }
            } else {
                HStack {
                    Text("Track your \n study time")
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    
                    Image(systemName: "timer.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                .frame(width: 150, height: 150)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // Update the time variable with the current stopwatch time
                time = vm.fetchStopWatchTimes()
            }
        }
    }
}

#Preview {
    CustomTrackTimeIcon()
}
