import Foundation
import UserNotifications

extension UNMutableNotificationContent {
    static func makeExerciseContent(from exercise: UpcomingExercise) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        // Emoji ve ikon kombinasyonu ile başlık
        let icon = exercise.iconName.replacingOccurrences(of: "figure.", with: "")
        let emoji = getEmoji(for: icon)
        content.title = "\(emoji) \(exercise.name)"
        
        // Alt başlık olarak süre
        content.subtitle = "⏱️ \(exercise.duration) dakika"
        
        // Ana mesaj
        content.body = """
        Sağlıklı bir yaşam için egzersiz zamanı! 🎯
        
        💪 Egzersizi tamamladığınızda "Tamamlandı" butonuna basın
        🔄 Şu an müsait değilseniz "Atla" butonunu kullanın
        """
        
        // Özel bildirim sesi
        content.sound = UNNotificationSound.default
        
        // Bildirim kategorisi (butonlar için)
        content.categoryIdentifier = "EXERCISE_ACTIONS"
        
        // Ek bilgiler
        content.userInfo = [
            "exerciseId": exercise.id,
            "exerciseName": exercise.name,
            "scheduledTime": exercise.scheduledTime.timeIntervalSince1970
        ]
        
        // Bildirim thread identifier'ı (gruplamak için)
        content.threadIdentifier = "exercise_notifications"
        
        return content
    }
    
    // Egzersiz tipine göre emoji seç
    private static func getEmoji(for icon: String) -> String {
        switch icon {
        case "walk": return "🚶"
        case "run": return "🏃"
        case "dance": return "💃"
        case "yoga": return "🧘"
        case "gym": return "🏋️"
        case "swim": return "🏊"
        case "bike": return "🚴"
        case "eye": return "👁️"
        case "neck": return "🧘"
        case "stretch": return "🤸"
        default: return "💪"
        }
    }
}
