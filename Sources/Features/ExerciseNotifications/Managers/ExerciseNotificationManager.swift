import Foundation
import UserNotifications

final class ExerciseNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ExerciseNotificationManager()
    private let service: ExerciseNotificationServiceProtocol
    
    init(service: ExerciseNotificationServiceProtocol = ExerciseNotificationService.shared) {
        self.service = service
        super.init()
        UNUserNotificationCenter.current().delegate = self
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
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotificationResponse(response)
        completionHandler()
    }
    
    // Bildirim yanıtlarını işle
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        // UserInfo'dan exerciseId'yi al
        guard let exerciseId = response.notification.request.content.userInfo["exerciseId"] as? String else {
            return
        }
        
        // Aksiyon tipini kontrol et
        let action: ExerciseAction
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier: // Bildirime tıklandı
            action = .complete
        case UNNotificationDismissActionIdentifier: // Bildirim kapatıldı
            action = .skip
        default:
            // Özel aksiyonlar (Tamamla/Atla butonları)
            action = ExerciseAction(rawValue: response.actionIdentifier) ?? .skip
        }
        
        // Service'e ilet
        Task {
            do {
                try await service.handleNotificationResponse(exerciseId: exerciseId, action: action)
            } catch {
                print("⚠️ Bildirim yanıtı işlenemedi:", error.localizedDescription)
            }
        }
    }
    
    // Tüm bildirimleri iptal et
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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
            
            // İlk 30 bildirimi planla (iOS limiti nedeniyle)
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
