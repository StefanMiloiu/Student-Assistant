//
//  ContentView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        CoordinatorView()
    }
}

#Preview {
    ContentView()
        .environmentObject(ExamListViewModel())
        .environmentObject(AppCoordinatorImpl())
}
