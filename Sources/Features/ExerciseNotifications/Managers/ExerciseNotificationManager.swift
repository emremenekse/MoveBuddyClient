import Foundation
import UserNotifications

final class ExerciseNotificationManager {
    static let shared = ExerciseNotificationManager()
    private let service: ExerciseNotificationServiceProtocol
    
    private init(service: ExerciseNotificationServiceProtocol = ExerciseNotificationService.shared) {
        self.service = service
        configureNotificationCategories()
    }
    
    // Bildirim kategorilerini ve butonlarını ayarla
    private func configureNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: ExerciseAction.complete.rawValue,
            title: "Tamamlandı",
            options: .foreground
        )
        
        let skipAction = UNNotificationAction(
            identifier: ExerciseAction.skip.rawValue,
            title: "Atla",
            options: .foreground
        )
        
        let category = UNNotificationCategory(
            identifier: "EXERCISE_ACTIONS",
            actions: [completeAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // Birden fazla egzersiz için bildirimleri planla
    func scheduleExerciseNotifications(exercises: [UpcomingExercise]) {
        Task {
            for exercise in exercises {
                do {
                    try await service.scheduleNotification(for: exercise)
                } catch {
                    print("⚠️ Bildirim planlanamadı: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Bildirim yanıtlarını işle
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let exerciseId = response.notification.request.identifier
        
        guard let action = ExerciseAction(rawValue: response.actionIdentifier) else {
            return
        }
        
        Task {
            do {
                try await service.handleNotificationResponse(exerciseId: exerciseId, action: action)
            } catch {
                print("⚠️ Bildirim yanıtı işlenemedi: \(error.localizedDescription)")
            }
        }
    }
}
