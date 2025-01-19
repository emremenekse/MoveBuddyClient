//
//  MoveBuddyApp.swift
//  MoveBuddy
//
//  Created by Umut Emre Menekşe on 14.01.2025.
//

import SwiftUI
import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase'i yapılandır
        FirebaseService.shared.configure()
        
        // Push bildirimleri yapılandır
        PushNotificationService.shared.configure()
        
        return true
    }
    
    // MARK: - Remote Notification Registration
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("📱 Successfully registered for remote notifications with token")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

@main
struct MoveBuddyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appViewModel.currentFlow {
                case .determining:
                    ProgressView()
                        .onAppear {
                            appViewModel.determineInitialFlow()
                        }
                case .onboarding:
                    OnboardingView(appViewModel: appViewModel)
                case .authentication:
                    AuthenticationView(appViewModel: appViewModel)
                case .main:
                    ContentView()
                }
            }
            .environmentObject(appViewModel)
            .handleErrors()
            .onAppear {
                setupGlobalErrorHandling()
            }
        }
    }
    
    private func setupGlobalErrorHandling() {
        Task { @MainActor in
            for await error in ErrorHandlingService.shared.errorStream() {
                ErrorHandlingService.shared.handle(error)
            }
        }
    }
}
