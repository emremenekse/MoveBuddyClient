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
        content.title = "Egzersiz Zamanı!"
        content.body = "\(exercise.name) egzersizini yapma zamanı geldi"
        content.sound = .default
        content.categoryIdentifier = "EXERCISE_ACTIONS"
        
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
    
    func handleNotificationResponse(exerciseId: String, action: ExerciseAction) async throws {
        switch action {
        case .complete:
            print("Egzersiz tamamlandı: \(exerciseId)")
        case .skip:
            print("Egzersiz atlandı: \(exerciseId)")
        }
    }
    
    func cancelNotification(for exerciseId: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [exerciseId])
    }
}
