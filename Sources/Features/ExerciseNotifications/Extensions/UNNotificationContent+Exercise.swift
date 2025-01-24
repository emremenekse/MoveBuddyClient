import Foundation
import UserNotifications

extension UNMutableNotificationContent {
    static func makeExerciseContent(from exercise: UpcomingExercise) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        // Temel bildirim içeriği
        content.title = "💪 Egzersiz Zamanı!"
        content.body = "\(exercise.name) egzersizini yapma zamanı geldi"
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
