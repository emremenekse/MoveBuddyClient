import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseCore
import UIKit

final class PushNotificationService: NSObject {
    static let shared = PushNotificationService()
    private let httpService: HttpServiceProtocol
    private let fcmBaseURL = "https://fcm.googleapis.com/fcm/send"
    
    private override init() {
        self.httpService = HttpService.shared
        super.init()
    }
    
    func configure() {
        UNUserNotificationCenter.current().delegate = self
        requestAuthorization()
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        Messaging.messaging().isAutoInitEnabled = true
        configureFCM()
        
        subscribeToTopic("all_users")
    }
    
    private func requestAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        return
                    }
                }
            }
        )
    }
    
    private func configureFCM() {
        Messaging.messaging().delegate = self
    }
    
    private func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            DispatchQueue.main.async {
                if let error = error {
                    return
                }
            }
        }
    }
    
    // FCM üzerinden bildirim gönderme
    func sendPushNotification(_ notification: NotificationModel, to token: String) async throws {
        guard let url = URL(string: fcmBaseURL) else {
            throw HttpError.invalidURL
        }
        
        let headers = ["Authorization": "key=YOUR_SERVER_KEY"]
        let message = FCMMessage(
            to: token,
            notification: .init(title: notification.title, body: notification.body),
            data: .init(type: notification.type.rawValue)
        )
        
        let _: Data = try await httpService.request(
            url: url,
            method: .post,
            body: message,
            headers: headers
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension PushNotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        DispatchQueue.main.async {
            guard let token = fcmToken else {
                return
            }
            
        }
    }
}

// MARK: - FCM Message Types
private extension PushNotificationService {
    struct FCMMessage: Encodable {
        let to: String
        let notification: FCMNotification
        let data: FCMData
        
        struct FCMNotification: Encodable {
            let title: String
            let body: String
        }
        
        struct FCMData: Encodable {
            let type: String
        }
    }
} 