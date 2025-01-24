import Foundation

struct ExerciseNotification: Identifiable, Codable {
    let id: String
    let exerciseId: String
    let scheduledTime: Date
    let status: NotificationStatus
    let exerciseDetails: UpcomingExercise
    
    enum NotificationStatus: String, Codable {
        case pending   // Bildirim beklemede
        case completed // Egzersiz tamamlandı
        case skipped   // Egzersiz atlandı
        case missed    // Egzersiz kaçırıldı
    }
}
