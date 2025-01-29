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
            options: [.customDismissAction, .hiddenPreviewsShowTitle]
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
        
        // UserInfo'dan exerciseId'yi al
        guard let exerciseId = response.notification.request.content.userInfo["exerciseId"] as? String else {
            return
        }
        
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
    
    // Tüm bildirimleri iptal et
    func cancelAllNotifications() {
        print("🔴 Tüm bildirimleri iptal et")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Belirli bir egzersizin bildirimlerini iptal et
    func cancelNotifications(for exerciseId: String) async {
        await service.cancelNotification(for: exerciseId)
    }
    
    // Bildirimleri yeniden planla
    func rescheduleNotifications(exercises: [UpcomingExercise]) {
        Task {
            // Önce tüm bildirimleri iptal et
            cancelAllNotifications()
            
            // İlk 10 bildirimi planla (iOS limiti nedeniyle)
            let limitedExercises = Array(exercises.prefix(30))
            print("🔔 Planlanan bildirim sayısı:", limitedExercises.count)
            
            for exercise in limitedExercises {
                do {
                    try await service.scheduleNotification(for: exercise)
                } catch {
                    print("⚠️ Bildirim planlanamadı:", error.localizedDescription)
                }
            }
        }
    }
}
