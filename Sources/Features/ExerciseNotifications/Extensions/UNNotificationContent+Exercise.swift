import Foundation
import UserNotifications

extension UNMutableNotificationContent {
    static func makeExerciseContent(from exercise: UpcomingExercise) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        // Temel bildirim içeriği
        content.title = "\(exercise.iconName) \(exercise.name) Zamanı!"
        content.subtitle = "Egzersiz süresi: \(exercise.duration) dakika"
        content.body = "Sağlıklı bir yaşam için hemen başlayın! Tamamlandı'ya basarak egzersizi tamamlayabilirsiniz."
        content.sound = .default
        
        // Bildirim kategorisini ayarla (butonlar için)
        content.categoryIdentifier = "EXERCISE_ACTIONS"
        
        // Ek bilgileri userInfo olarak ekle
        content.userInfo = [
            "exerciseId": exercise.id,
            "exerciseName": exercise.name,
            "scheduledTime": exercise.scheduledTime.timeIntervalSince1970
        ]
        
        return content
    }
}
