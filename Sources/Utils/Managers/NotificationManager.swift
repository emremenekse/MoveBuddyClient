import SwiftUI
import Combine

final class NotificationManager: ObservableObject {
    @Published var pendingNotifications: [NotificationModel] = []
    private let service: NotificationServiceProtocol
    
    init(service: NotificationServiceProtocol = NotificationService.shared) {
        self.service = service
    }
    
    func scheduleLocalNotification(_ notification: NotificationModel) async throws {
        try await service.scheduleLocalNotification(notification)
        pendingNotifications.append(notification)
    }
    
    func sendPushNotification(to token: String, notification: NotificationModel) async throws {
        try await PushNotificationService.shared.sendPushNotification(notification, to: token)
    }
}
