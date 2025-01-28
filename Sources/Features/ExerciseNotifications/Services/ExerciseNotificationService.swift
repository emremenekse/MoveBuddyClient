import Foundation
import UserNotifications

enum ExerciseAction: String {
    case complete = "COMPLETE_EXERCISE"
    case skip = "SKIP_EXERCISE"
}

protocol ExerciseNotificationServiceProtocol {
    func scheduleNotification(for exercise: UpcomingExercise) async throws
    func handleNotificationResponse(exerciseId: String, action: ExerciseAction) async throws
    func cancelNotification(for exerciseId: String) async
}

final class ExerciseNotificationService: ExerciseNotificationServiceProtocol {
    static let shared = ExerciseNotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    func scheduleNotification(for exercise: UpcomingExercise) async throws {
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
        
        content.sound = .default
        content.categoryIdentifier = "EXERCISE_ACTIONS"
        content.threadIdentifier = "exercise_notifications"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], 
            from: exercise.scheduledTime),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: exercise.id,
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    // Egzersiz tipine göre emoji seç
    private func getEmoji(for icon: String) -> String {
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
    
    func handleNotificationResponse(exerciseId: String, action: ExerciseAction) async throws {
        switch action {
        case .complete:
            print("✅ Egzersiz tamamlandı: \(exerciseId)")
            await MainActor.run {
                UserExercisesService.shared.completeExercise(exerciseId)
            }
        case .skip:
            print("⏭️ Egzersiz atlandı: \(exerciseId)")
            // TODO: Skip işlemi için ayrı bir mantık eklenebilir
        }
    }
    
    func cancelNotification(for exerciseId: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [exerciseId])
    }
}
