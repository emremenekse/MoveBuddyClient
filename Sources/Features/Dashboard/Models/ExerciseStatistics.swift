import Foundation

// Tek bir egzersiz için günlük istatistik
struct DailyExerciseStats: Codable {
    let date: Date
    let exerciseId: String
    var notificationCount: Int  // Gönderilen hatırlatma sayısı
    var completedCount: Int     // Tamamlandı olarak işaretlenen sayısı
    var skippedCount: Int       // Geçilen/Ertelenen sayısı
}

// Günlük toplam istatistik
struct DailySummary: Codable {
    let date: Date
    let totalNotifications: Int
    let totalCompleted: Int
    let totalSkipped: Int
    let mostFrequentExerciseId: String?
    
    var completionRate: Double {
        guard totalNotifications > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalNotifications) * 100
    }
}

// Haftalık toplam istatistik
struct WeeklySummary: Codable {
    let weekStartDate: Date
    let totalExercises: Int
    let averageCompletionRate: Double
    let bestDay: Date
    let bestDayCompletionRate: Double
    let mostFrequentExerciseId: String?
    
    // Haftalık trend (son 7 gün)
    let dailyCompletionRates: [Double]  // Son 7 günün tamamlanma oranları
} 