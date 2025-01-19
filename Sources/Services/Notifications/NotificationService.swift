import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestPermission() async throws -> Bool
    func scheduleLocalNotification(_ notification: NotificationModel) async throws
}

final class NotificationService: NotificationServiceProtocol {
    static let shared = NotificationService()
    private init() {}
    
    func requestPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    func scheduleLocalNotification(_ notification: NotificationModel) async throws {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
    }
}
