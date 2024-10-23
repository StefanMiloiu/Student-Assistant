//
//  Coordinator.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 16.10.2024.
//

import Foundation
import SwiftUI

// MARK: - Screen Enum
/// Represents different screens in the app that can be navigated to.
enum Screen: String, Identifiable, Hashable {
    case dashboard  /// Dashboard
    case home       /// Home
    case signUp     /// Sign Up
    case logIn      /// LogIn screen
    case forgotPassword /// Forgot Password screen
    case assignments /// Assignments screen
    case exams      /// Exams screen

    var id: String { return self.rawValue }
}

// MARK: - Sheet Enum
/// Represents different sheets that can be presented modally.
enum Sheet: String, Identifiable, Hashable {
    case examsList  /// Sheet displaying the list of exams
    case calendarInfo  /// Sheet displaying calendar information
    
    var id: String { return self.rawValue }
}

// MARK: - FullScreenCover Enum
/// Represents different full-screen covers that can be presented.
enum FullScreenCover: String, Identifiable, Hashable {
    case assignmentDetails  /// Full screen cover for assignment details
    case examDetails        /// Full screen cover for exam details
    
    var id: String { return self.rawValue }
}

// MARK: - AppCoordinatorProtocol
/// Protocol defining the necessary functions for coordinating navigation and presentation in the app.
protocol AppCoordinatorProtocol: ObservableObject {
    var path: NavigationPath { get set }
    var sheet: Sheet? { get set }
    var fullScreenCover: FullScreenCover? { get set }
    
    func push(_ screen: Screen)
    func presentSheet(_ sheet: Sheet)
    func presentFullScreenCover(_ fullScreenCover: FullScreenCover)
    func pop()
    func popToRoot()
    func dismissSheet()
    func dismissFullScreenOver()
}

// MARK: - AppCoordinatorImpl
/// Class that implements `AppCoordinatorProtocol` to manage navigation and presentation in the app.
class AppCoordinatorImpl: AppCoordinatorProtocol, ObservableObject {
    @Published var path: NavigationPath = NavigationPath()   /// Stack-based navigation path
    @Published var sheet: Sheet?                             /// Currently presented sheet
    @Published var fullScreenCover: FullScreenCover?         /// Currently presented full-screen cover
    
    @Published var selectedYear: Int?                        /// Selected year in the app's context
    @Published var selectedMonth: Int?                       /// Selected month in the app's context
    
    // MARK: - Navigation Functions
    /// Pushes a new screen onto the navigation path.
    func push(_ screen: Screen) {
        path.append(screen)
    }
    /// Presents a modal sheet.
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    /// Presents a full-screen cover.
    func presentFullScreenCover(_ fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }
    
    /// Pops the last screen from the navigation path.
    func pop() {
        path.removeLast()
    }
    
    /// Pops all screens and returns to the root screen.
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    /// Dismisses the currently presented sheet.
    func dismissSheet() {
        self.sheet = nil
    }
    
    /// Dismisses the currently presented full-screen cover.
    func dismissFullScreenOver() {
        self.fullScreenCover = nil
    }
    
    // MARK: - Presentation Style Providers
    /// Builds a view for a specific screen.
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .logIn:
            LogInView()          /// LogIn view
        case .signUp:
            SignUpView()
        case .forgotPassword:
            ForgotPasswordView()
        case .dashboard:
            DashboardView()
        case .home:
            MainView()           /// Home screen view
        case .assignments:
            AssignmentsView()     /// Assignments view
        case .exams:
            ExamsCalendarView()   /// Exams calendar view
        }
    }
    
    /// Builds a view for a specific sheet.
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        switch sheet {
        case .calendarInfo:
            CalendarInfoView()    /// Calendar info view
        case .examsList:
            ExamsListView(
                selectedYear: Binding(get: { self.selectedYear }, set: { self.selectedYear = $0 }),
                selectedMonth: Binding(get: { self.selectedMonth }, set: { self.selectedMonth = $0 })
            )
        }
    }
    
    /// Builds a view for a specific full-screen cover (currently empty).
    @ViewBuilder
    func build(_ fullScreenCover: FullScreenCover) -> some View {
        // Full-screen cover logic to be implemented here
    }
}
