//
//  CoordinatorView.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 21.10.2024.
//

import SwiftUI

// MARK: - CoordinatorView
/// This view coordinates navigation, sheet presentation, and full-screen cover handling.
struct CoordinatorView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    /// The app's coordinator for managing navigation and modals

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
            // Initial view (home screen)
            appCoordinator.build(UserDefaults().isLoggedIn ? .home : .logIn)
                .navigationDestination(for: Screen.self) { screen in
                    appCoordinator.build(screen)
                }
                .sheet(item: $appCoordinator.sheet) { sheet in
                    appCoordinator.build(sheet)
                }
                .fullScreenCover(item: $appCoordinator.fullScreenCover) { fullScreenCover in
                    appCoordinator.build(fullScreenCover)
                }
        }
        .environmentObject(appCoordinator)
    }
}

// MARK: - Preview
#Preview {
    CoordinatorView()
}
