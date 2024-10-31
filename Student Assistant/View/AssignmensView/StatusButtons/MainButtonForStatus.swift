//
//  MainButtonForStatus.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 13.10.2024.
//

import SwiftUI

struct MainButtonForStatus: View {

    @Binding var showStatusButtons: Bool

    var body: some View {
        Button(action: {
            showStatusButtons.toggle()
        }) {
            Image(systemName: "square.and.pencil.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(6)
                .foregroundStyle(.white)
                .frame(width: 60, height: 40)
                .aspectRatio(contentMode: .fit)
                .background(Color.gray.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
