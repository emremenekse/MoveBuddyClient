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
import FirebaseAuth   
import FirebaseFirestore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase'i yapılandır
        FirebaseService.shared.configure()
        
        // Push bildirimleri yapılandır
        PushNotificationService.shared.configure()
        
        // Bildirim delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = self
        
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
    
    // MARK: - Notification Delegate Methods
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Bildirim yanıtını ExerciseNotificationManager'a ilet
        ExerciseNotificationManager.shared.handleNotificationResponse(response)
        completionHandler()
    }
    
    // Uygulama açıkken bildirim geldiğinde
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Bildirimi banner olarak göster ve ses çal
        completionHandler([.banner, .sound])
    }
}

@main
struct MoveBuddyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // MARK: - Global Services
    @StateObject private var loadingService = LoadingService.shared
    @StateObject private var errorHandlingService = ErrorHandlingService.shared
    @StateObject private var authenticationService = AuthenticationService.shared
    @StateObject private var appViewModel = AppViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                appViewModel.currentFlow.view
            }
            // Global servisleri environment'a ekle
            .environmentObject(loadingService)
            .environmentObject(errorHandlingService)
            .environmentObject(authenticationService)
            .environmentObject(appViewModel)
            // View modifier'ları
            .withLoading(loadingService)
            .handleErrors()
            .task {
                do {
                    try await setupGlobalErrorHandling()
                } catch {
                    print("Global error handling setup failed: \(error)")
                }
            }
        }
    }
    
    private func setupGlobalErrorHandling() async throws {
        for try await error in ErrorHandlingService.shared.errorStream() {
            ErrorHandlingService.shared.handle(error)
        }
    }
}
