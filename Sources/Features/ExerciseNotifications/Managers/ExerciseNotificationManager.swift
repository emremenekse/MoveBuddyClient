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
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Uygulama açıkken bildirimleri göster
        completionHandler([.banner, .sound, .badge])
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
            writeExercisesToFile(limitedExercises)
            
            for exercise in limitedExercises {
                do {
                    try await service.scheduleNotification(for: exercise)
                } catch {
                }
            }
        }
    }
    
    private func writeExercisesToFile(_ exercises: [UpcomingExercise]) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("planned_exercises.txt")
        
        
        do {
            // Eğer dosya yoksa oluştur
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }
            
            // Convert exercises to string representation
            let exerciseStrings = exercises.map { "Exercise: \($0)" }.joined(separator: "\n")
            // Write to file, this will overwrite existing content
            try exerciseStrings.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
        }
    }
}
