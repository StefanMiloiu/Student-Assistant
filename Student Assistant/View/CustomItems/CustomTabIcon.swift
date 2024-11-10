//
//  CustomTabIcon.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 10.11.2024.
//

import SwiftUI

struct CustomTabIconView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit() // Scales the image while maintaining aspect ratio
                .frame(width: 20, height: 20) // Set the desired size here
            Text(title)
                .font(.caption) // Adjust font size if necessary
        }
        .frame(width: 20, height: 20) // Set the desired size here
    }
}

#Preview {
    CustomTabIconView(title: "Title", imageName: "Icon")
}
