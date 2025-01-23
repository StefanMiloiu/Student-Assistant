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
enum Screen: Identifiable, Hashable {
    
    case dashboard      /// Dashboard
    case home           /// Home
    case signUp         /// Sign Up
    case logIn          /// LogIn screen
    case forgotPassword /// Forgot Password screen
    case assignments    /// Assignments screen
    case exams          /// Exams screen
    case addExam
    case custom(AnyView) // New case for custom views
    case smartAssistantMainView
    case OCRAndAIView
    
    // Conformance to Identifiable
    var id: String {
        switch self {
        case .custom(let view):
            return String(describing: view)
        default:
            return String(describing: self)
        }
    }
    
    // Conformance to Equatable
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case (.dashboard, .dashboard),
            (.home, .home),
            (.signUp, .signUp),
            (.logIn, .logIn),
            (.forgotPassword, .forgotPassword),
            (.assignments, .assignments),
            (.exams, .exams):
            return true
        case (.custom(let lhsView), .custom(let rhsView)):
            return String(describing: lhsView) == String(describing: rhsView)
        default:
            return false
        }
    }
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .dashboard:
            hasher.combine("dashboard")
        case .home:
            hasher.combine("home")
        case .signUp:
            hasher.combine("signUp")
        case .logIn:
            hasher.combine("logIn")
        case .forgotPassword:
            hasher.combine("forgotPassword")
        case .assignments:
            hasher.combine("assignments")
        case .exams:
            hasher.combine("exams")
        case .custom(let view):
            hasher.combine(String(describing: view))
        case .addExam:
            hasher.combine("addExam")
        case .smartAssistantMainView:
            hasher.combine("smartAssistantMainView")
        case .OCRAndAIView:
            hasher.combine("ocrAndAIView")
        }
    }
}

// MARK: - Sheet Enum
/// Represents different sheets that can be presented modally.
enum Sheet: Identifiable, Hashable {
    case custom(AnyView)
    
    var id: String {
        switch self {
        case .custom:
            return "custom"
        }
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        switch (lhs, rhs) {
        case (.custom, .custom):
            return true
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
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
    
    func pushCustom<V: View>(_ customView: V) {
        path.append(Screen.custom(AnyView(customView)))
    }
    
    func presentCustomSheet<V: View>(_ customView: V) {
        self.sheet = Sheet.custom(AnyView(customView))
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
            ExamsMainView()   /// Exams calendar view
        case .addExam:
            AddExamView()
        case .custom(let customView):
            customView
        case .smartAssistantMainView:
            MainAssistantView()
        case .OCRAndAIView:
            OCRAndAIView()
        }
    }
    
    /// Builds a view for a specific sheet.
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        switch sheet {
        case .custom(let customView):
            customView
        }
    }
    
    /// Builds a view for a specific full-screen cover (currently empty).
    @ViewBuilder
    func build(_ fullScreenCover: FullScreenCover) -> some View {
        // Full-screen cover logic to be implemented here
    }
}
