import Foundation
import Combine

@MainActor
final class StatisticsService {
    // MARK: - Singleton
    static let shared = StatisticsService()
    
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let dailyStatsKey = "dailyExerciseStats"
    
    @Published private(set) var todaySummary: DailySummary?
    @Published private(set) var weeklySummary: WeeklySummary?
    
    // MARK: - Initialization
    private init() {
        loadStatistics()
    }
    
    // MARK: - Public Methods
    
    // Bildirim gönderildiğinde çağrılır
    func recordNotification(exerciseId: String) {
        updateDailyStats(exerciseId: exerciseId) { stats in
            var stats = stats
            stats.notificationCount += 1
            return stats
        }
    }
    
    // Kullanıcı egzersizi tamamladığında çağrılır
    func recordCompletion(exerciseId: String) {
        updateDailyStats(exerciseId: exerciseId) { stats in
            var stats = stats
            stats.completedCount += 1
            return stats
        }
    }
    
    // Kullanıcı egzersizi ertelediğinde/geçtiğinde çağrılır
    func recordSkipped(exerciseId: String) {
        updateDailyStats(exerciseId: exerciseId) { stats in
            var stats = stats
            stats.skippedCount += 1
            return stats
        }
    }
    
    // Günlük özeti hesaplar
    func calculateTodaySummary() -> DailySummary {
        let today = Calendar.current.startOfDay(for: Date())
        let stats = loadDailyStats().filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
        
        let totalNotifications = stats.reduce(0) { $0 + $1.notificationCount }
        let totalCompleted = stats.reduce(0) { $0 + $1.completedCount }
        let totalSkipped = stats.reduce(0) { $0 + $1.skippedCount }
        
        // En çok hatırlatma gönderilen egzersizi bul
        let mostFrequent = stats.max { a, b in a.notificationCount < b.notificationCount }
        
        return DailySummary(
            date: today,
            totalNotifications: totalNotifications,
            totalCompleted: totalCompleted,
            totalSkipped: totalSkipped,
            mostFrequentExerciseId: mostFrequent?.exerciseId
        )
    }
    
    // Haftalık özeti hesaplar
    func calculateWeeklySummary() -> WeeklySummary {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today)!
        
        var dailyRates: [Double] = []
        var bestDay = today
        var bestRate = 0.0
        var totalRate = 0.0
        var totalExercises = 0
        
        // Son 7 günün istatistiklerini hesapla
        for dayOffset in 0...6 {
            let date = calendar.date(byAdding: .day, value: dayOffset-6, to: today)!
            let dayStats = loadDailyStats().filter { calendar.isDate($0.date, inSameDayAs: date) }
            
            let notifications = dayStats.reduce(0) { $0 + $1.notificationCount }
            let completed = dayStats.reduce(0) { $0 + $1.completedCount }
            
            let rate = notifications > 0 ? Double(completed) / Double(notifications) * 100 : 0
            dailyRates.append(rate)
            totalRate += rate
            totalExercises += completed
            
            if rate > bestRate {
                bestRate = rate
                bestDay = date
            }
        }
        
        // En çok yapılan egzersizi bul
        let allStats = loadDailyStats().filter { $0.date >= weekStart && $0.date <= today }
        let exerciseCounts = allStats.reduce(into: [:]) { counts, stat in
            counts[stat.exerciseId, default: 0] += stat.completedCount
        }
        let mostFrequent = exerciseCounts.max { $0.value < $1.value }?.key
        
        return WeeklySummary(
            weekStartDate: weekStart,
            totalExercises: totalExercises,
            averageCompletionRate: totalRate / 7.0,
            bestDay: bestDay,
            bestDayCompletionRate: bestRate,
            mostFrequentExerciseId: mostFrequent,
            dailyCompletionRates: dailyRates
        )
    }
    
    // MARK: - Private Methods
    private func loadStatistics() {
        todaySummary = calculateTodaySummary()
        weeklySummary = calculateWeeklySummary()
    }
    
    private func loadDailyStats() -> [DailyExerciseStats] {
        guard let data = defaults.data(forKey: dailyStatsKey),
              let stats = try? JSONDecoder().decode([DailyExerciseStats].self, from: data) else {
            return []
        }
        return stats
    }
    
    private func saveDailyStats(_ stats: [DailyExerciseStats]) {
        guard let data = try? JSONEncoder().encode(stats) else { return }
        defaults.set(data, forKey: dailyStatsKey)
        
        // İstatistikleri güncelle
        loadStatistics()
    }
    
    private func updateDailyStats(exerciseId: String, update: (DailyExerciseStats) -> DailyExerciseStats) {
        let today = Calendar.current.startOfDay(for: Date())
        var stats = loadDailyStats()
        
        if let index = stats.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) && 
            $0.exerciseId == exerciseId 
        }) {
            stats[index] = update(stats[index])
        } else {
            // Yeni istatistik oluştur
            let newStat = DailyExerciseStats(
                date: today,
                exerciseId: exerciseId,
                notificationCount: 0,
                completedCount: 0,
                skippedCount: 0
            )
            stats.append(update(newStat))
        }
        
        saveDailyStats(stats)
    }
} 