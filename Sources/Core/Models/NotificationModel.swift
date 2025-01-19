import Foundation

 struct NotificationModel: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let type: NotificationType
    let timestamp: Date
    
    enum NotificationType: String, Codable {
        case exercise
        case reminder
        case profile
        case statistics
    }
}