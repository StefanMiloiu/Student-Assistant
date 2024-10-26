//
//  Student_AssistantApp.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Student_AssistantApp: App {
    
    @StateObject var appCoordinator: AppCoordinatorImpl = AppCoordinatorImpl()
    @StateObject var examViewModel: ExamListViewModel = ExamListViewModel()
    @StateObject var assignmentsViewModel: AssignmentListViewModel = AssignmentListViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(examViewModel)
                .environmentObject(appCoordinator)
                .environmentObject(assignmentsViewModel)
        }
    }
}
