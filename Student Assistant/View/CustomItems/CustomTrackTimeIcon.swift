//
//  CustomTrackTimeIcon.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 15.10.2024.
//

import SwiftUI

struct CustomTrackTimeIcon: View {
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
}

#Preview {
    CustomTrackTimeIcon()
}
