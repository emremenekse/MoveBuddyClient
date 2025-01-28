import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var completedExercises: Int = 0
    @Published var remainingExercises: Int = 0
    @Published var totalMinutes: Int = 0
    @Published var upcomingExercises: [UpcomingExercise] = []
    @Published var weeklyTotal: Int = 0
    @Published var weeklyAverage: Double = 0
    @Published var weeklyBest: Int = 0
    
    // Günlük özet için hesaplanan değerler
    var completedToday: Int {
        userExercisesService.completedExercises
            .filter { Calendar.current.isDateInToday($0.completedAt) }
            .count
    }
    
    var remainingToday: Int {
        allUpcomingExercisesForTodayTarget
            .filter { Calendar.current.isDateInToday($0.1) }
            .count
    }
    
    var completedMinutesToday: Int {
        let todayCompleted = userExercisesService.completedExercises
            .filter { Calendar.current.isDateInToday($0.completedAt) }
        
        return todayCompleted.reduce(0) { total, completed in
            if let exercise = exercisesService.exercises.first(where: { $0.id == completed.exerciseId }) {
                return total + (exercise.durationSeconds ?? 0) / 60
            }
            return total
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var initialSetupService: InitialSetupService
    private var exercisesService: ExercisesService
    private var userExercisesService: UserExercisesService
    private var workSchedule: WorkSchedule?
    private let notificationManager = ExerciseNotificationManager.shared
    private let calendar = Calendar.current
    
    // Tüm yaklaşan egzersizleri tutan private property
    private var allUpcomingExercises: [(Exercise, Date)] = []
    private var allUpcomingExercisesForTodayTarget: [(Exercise, Date)] = []
    
    init() {
        // Servisleri init sırasında başlat
        initialSetupService = .shared
        exercisesService = .shared
        userExercisesService = .shared
        
        // Verileri yükle
        Task {
            await loadUserInfo()
            await loadExercises()
        }
        
        // Egzersiz değişikliklerini dinle
        setupSubscriptions()
    }
    
    func refreshData() async {
        await loadExercises()
    }
    
    private func loadUserInfo() async {
        guard let userInfo = try? await initialSetupService.getUserInfo() else { return }
        userName = userInfo.name
        workSchedule = userInfo.workSchedule
    }
    
    private func loadExercises() async {
        await exercisesService.fetchExercises()
        
        // Günlük özet için gerçek data
        let exercises = exercisesService.exercises
        let selectedExercises = userExercisesService.selectedExercises
        print("🔔 Seçili egzersizler:", selectedExercises)
        
        
        // Tamamlanma durumunu şimdilik 0 olarak bırakıyoruz
        // TODO: Tamamlanma durumu için bir mekanizma eklenecek
        completedExercises = 0
        remainingExercises = selectedExercises.count
        
        // Seçili egzersizlerin toplam süresi
        totalMinutes = selectedExercises.compactMap { selectedExercise in
            exercises.first { $0.id == selectedExercise.exerciseId }?.durationSeconds
        }.reduce(0) { $0 + ($1 / 60) }
        
        // Yaklaşan egzersizler için gerçek data
        let now = Date()
        guard let schedule = workSchedule else {
            return
        }
        
        // Her egzersiz için gelecek zamanları al ve birleştir
        allUpcomingExercises = []
        allUpcomingExercisesForTodayTarget = []
        
        for selectedExercise in selectedExercises {
            guard let exercise = exercises.first(where: { $0.id == selectedExercise.exerciseId }) else {
                continue
            }
            
            // Bildirimler için daha uzun bir Süre al (örn: 1 hafta)
            let nextTimes = selectedExercise.reminderInterval.nextOccurrences(from: now, workSchedule: schedule, limit: 50)
            let exerciseTimes = nextTimes.map { (exercise, $0) }
            allUpcomingExercises.append(contentsOf: exerciseTimes)

            let nextTimesForTodayTarget = selectedExercise.reminderInterval.nextOccurrences(from: now, workSchedule: schedule, limit: 5000)
            let exerciseTimesForTodayTarget = nextTimesForTodayTarget.map { (exercise, $0) }
            allUpcomingExercisesForTodayTarget.append(contentsOf: exerciseTimesForTodayTarget)
        }
        
        // Tüm zamanları sırala
        allUpcomingExercises = allUpcomingExercises
            .filter { $0.1 > now }
            .sorted { $0.1 < $1.1 }
        
        // Bugünün egzersizlerini göster
        let todayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        let todayExercises = allUpcomingExercises
            .filter { calendar.isDate($0.1, inSameDayAs: now) }
            .prefix(5)
        
        // Eğer bugün için yeterli egzersiz yoksa, yarından itibaren olanları da ekle
        var displayExercises = Array(todayExercises)
        if displayExercises.count < 5 {
            let futureExercises = allUpcomingExercises
                .filter { $0.1 > todayEnd }
                .prefix(5 - displayExercises.count)
            displayExercises.append(contentsOf: futureExercises)
        }
        
        // Dashboard için egzersizleri formatla
        upcomingExercises = displayExercises
            .map { pair in
                let dateFormatter = DateFormatter()
                
                // Eğer aynı gündeyse sadece saat, değilse tarih ve saat göster
                if calendar.isDate(pair.1, inSameDayAs: now) {
                    dateFormatter.timeStyle = .short
                    dateFormatter.dateStyle = .none
                } else {
                    dateFormatter.timeStyle = .short
                    dateFormatter.dateStyle = .medium
                }
                
                return UpcomingExercise(
                    id: UUID().uuidString,
                    name: pair.0.name,
                    scheduledTime: pair.1,
                    time: dateFormatter.string(from: pair.1),
                    duration: pair.0.durationSeconds.map { $0 / 60 } ?? 0,
                    iconName: pair.0.categories.first?.icon ?? "figure.walk"
                )
            }
            
        // TÜM egzersizler için bildirimleri planla
        let allNotifications = allUpcomingExercises.map { pair in
            UpcomingExercise(
                id: UUID().uuidString,
                name: pair.0.name,
                scheduledTime: pair.1,
                time: "", // Bildirimler için time string'e gerek yok
                duration: pair.0.durationSeconds.map { $0 / 60 } ?? 0,
                iconName: pair.0.categories.first?.icon ?? "figure.walk"
            )
        }
        print("🔔 Toplam planlanacak bildirim sayısı:", allNotifications.count)
        notificationManager.rescheduleNotifications(exercises: allNotifications)
        
        // Haftalık istatistikler için gerçek data
        weeklyTotal = selectedExercises.count
        weeklyAverage = Double(selectedExercises.count) / 7.0
        weeklyBest = completedExercises // Şimdilik tamamlanan sayısını kullanıyoruz
    }
    
    private func setupSubscriptions() {
        // Seçili egzersizler değiştiğinde dashboard'u güncelle
        userExercisesService.exercisesPublisher
            .sink { [weak self] _ in
                Task {
                    await self?.loadExercises()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Models
struct UpcomingExercise: Identifiable, Codable {
    let id: String
    let name: String
    let scheduledTime: Date
    let time: String
    let duration: Int
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, scheduledTime, time, duration, iconName
    }
}