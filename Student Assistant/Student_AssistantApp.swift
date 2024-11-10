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
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct StudentAssistantApp: App {
    @StateObject var appCoordinator: AppCoordinatorImpl = AppCoordinatorImpl()
    @StateObject var examViewModel: ExamListViewModel = ExamListViewModel()
    @StateObject var assignmentsViewModel: AssignmentListViewModel = AssignmentListViewModel()
    @StateObject var locationManager = LocationManager()
    @StateObject var chatViewModel = ChatViewModel()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationsManager.requestNotificationPermission()
                    examViewModel.syncExams()
                    assignmentsViewModel.syncAssignments()
                }
                .environmentObject(examViewModel)
                .environmentObject(appCoordinator)
                .environmentObject(assignmentsViewModel)
                .environmentObject(locationManager)
                .environmentObject(chatViewModel)
        }
    }
}
