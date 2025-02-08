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
    
    private func requestNotificationPermission() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        
        if settings.authorizationStatus != .authorized {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
        }
    }
    
    func scheduleNotification(for exercise: UpcomingExercise) async throws {
        print("Scheduling notification for: \(exercise)")
        // Önce izin kontrolü yap
        try await requestNotificationPermission()
        
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
        content.threadIdentifier = "exercise_notifications"
        content.userInfo = [
            "exerciseId": exercise.exerciseId,
            "scheduledTime": exercise.scheduledTime.timeIntervalSince1970
        ]
        
        // Bildirim aksiyonlarını ekle
        let completeAction = UNNotificationAction(
            identifier: ExerciseAction.complete.rawValue,
            title: "Tamamla",
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
            options: [.customDismissAction] // Bildirim kapatıldığında tetiklenecek
        )
        
        // Kategoriyi kaydet
        notificationCenter.setNotificationCategories([category])
        content.categoryIdentifier = "EXERCISE_ACTIONS"
        
        // Bildirimin zamanını ayarla
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], 
            from: exercise.scheduledTime),
            repeats: false
        )
        
        // Bildirim isteğini oluştur
        let request = UNNotificationRequest(
            identifier: exercise.id,
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
        
        // Her 30 saniyede bir tüm bildirimleri kontrol et
        startNotificationCleanupTimer()
    }
    
    private static var cleanupTimer: Task<Void, Error>?
    
    private func startNotificationCleanupTimer() {
        // Eğer timer zaten çalışıyorsa yeni timer oluşturma
        guard Self.cleanupTimer == nil else { return }
        
        Self.cleanupTimer = Task {
            while !Task.isCancelled {
                // Her 30 saniyede bir kontrol et
                try await Task.sleep(nanoseconds: 30 * NSEC_PER_SEC)
                
                let notifications = await notificationCenter.deliveredNotifications()
                print("📬 Aktif bildirim sayısı: \(notifications.count)")
                
                var expiredNotifications: [String] = []
                
                for notification in notifications {
                    guard let scheduledTime = notification.request.content.userInfo["scheduledTime"] as? TimeInterval else {
                        continue
                    }
                    
                    let notificationDate = Date(timeIntervalSince1970: scheduledTime)
                    let timeSinceNotification = Date().timeIntervalSince(notificationDate)
                    
                    // 2 dakikadan eski bildirimleri topla
                    if timeSinceNotification >= 2 * 60 {
                        expiredNotifications.append(notification.request.identifier)
                    }
                }
                
                // Eğer süresi geçmiş bildirim varsa
                if !expiredNotifications.isEmpty {
                    print("🗑️ \(expiredNotifications.count) adet bildirimin süresi doldu, kaldırılıyor")
                    notificationCenter.removeDeliveredNotifications(withIdentifiers: expiredNotifications)
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: expiredNotifications)
                    
                    // Egzersiz listesini güncelle
                    // if !expiredNotifications.isEmpty {
                    //     await MainActor.run {
                    //         UserExercisesService.shared.skipExercise()
                    //     }
                    // }
                }
            }
        }
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
        // Bildirimi kaldır
        let notifications = await notificationCenter.deliveredNotifications()
        let notificationId = notifications.first { notification in
            guard let notificationExerciseId = notification.request.content.userInfo["exerciseId"] as? String else {
                return false
            }
            return notificationExerciseId == exerciseId
        }?.request.identifier
        
        if let id = notificationId {
            notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        }
        
        switch action {
        case .complete:
            print("✅ Egzersiz tamamlandı: \(exerciseId)")
            await MainActor.run {
                UserExercisesService.shared.completeExercise(exerciseId)
            }
        case .skip:
            print("⏭️ Egzersiz atlandı: \(exerciseId)")
            await MainActor.run {
                UserExercisesService.shared.skipExercise()
            }
        }
    }
    
    func cancelNotification(for exerciseId: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [exerciseId])
    }
}
