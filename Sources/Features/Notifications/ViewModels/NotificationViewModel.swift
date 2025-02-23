import SwiftUI
import Combine

final class NotificationViewModel: ObservableObject {
    @Published var isNotificationsEnabled = false
    @Published var notifications: [NotificationModel] = []
    
    private let manager: NotificationManager
    
    init(manager: NotificationManager = NotificationManager()) {
        self.manager = manager
    }
    
    func requestNotificationPermission() {
        Task {
            do {
                let granted = try await NotificationService.shared.requestPermission()
                await MainActor.run {
                    isNotificationsEnabled = granted
                }
            } catch {
            }
        }
    }
    
    func sendTestNotification() {
        let notification = NotificationModel(
            id: UUID().uuidString,
            title: "Test Bildirimi",
            body: "Bu bir test bildirimidir! 🎉",
            type: .exercise,
            timestamp: Date()
        )
        
        Task {
            do {
                try await manager.scheduleLocalNotification(notification)
                await MainActor.run {
                    notifications.append(notification)
                }
            } catch {
            }
        }
    }
}