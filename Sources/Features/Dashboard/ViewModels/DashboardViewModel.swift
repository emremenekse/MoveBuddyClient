import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject, UserExercisesServiceDelegate {
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
            } else {
                return total
            }
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
    
    // Egzersiz zamanlarının hesaplanma durumunu kontrol etmek için flag
    private var exerciseTimesCalculated = false
    
    // Son seçili egzersiz ID'lerini saklamak için
    private var lastSelectedExerciseIds: [String] = []
    
    init(initialSetupService: InitialSetupService = .shared,
         exercisesService: ExercisesService = .shared,
         userExercisesService: UserExercisesService = .shared) {
        self.initialSetupService = initialSetupService
        self.exercisesService = exercisesService
        self.userExercisesService = userExercisesService
        
        // Delegate'i ayarla
        userExercisesService.delegate = self
        
        setupSubscriptions()
        Task {
            await loadUserInfo()
            await loadExercises()
        }
    }
    
    func refreshData() async {
        await loadExercises()
    }
    
    private func loadUserInfo() async {
        guard let userInfo = try? await initialSetupService.getUserInfo() else { return }
        userName = userInfo.name
    }
    
    private func loadExercises() async {
        
        // Önce workSchedule'ı InitialSetupService'den al
        guard let userInfo = try? await initialSetupService.getUserInfo() else {
            return
        }
        let schedule = userInfo.workSchedule
        
        // Egzersizleri yükle ve bekle
        await exercisesService.fetchExercises()
        
        // Günlük özet için gerçek data
        let exercises = exercisesService.exercises
        let selectedExercises = userExercisesService.selectedExercises
        
        // Tamamlanma durumunu güncelle
        completedExercises = completedToday
        remainingExercises = selectedExercises.count
        
        // Toplam dakikayı güncelle
        totalMinutes = completedMinutesToday
        
        // Şu anki zamanı al
        let now = Date()
        
        // Seçili egzersizlerin ID'lerini al
        let currentSelectedExerciseIds = selectedExercises.map { $0.exerciseId }
        
        // Egzersiz zamanlarını sadece aşağıdaki durumlarda yeniden hesapla:
        // 1. Hiç hesaplanmamışsa (ilk çağrı)
        // 2. Seçili egzersizler değişmişse
        let shouldRecalculateTimes = !exerciseTimesCalculated || 
                                     currentSelectedExerciseIds != lastSelectedExerciseIds
        
        if shouldRecalculateTimes {
            print("Egzersiz zamanları yeniden hesaplanıyor...")
            
            // Tüm yaklaşan egzersizleri temizle
            allUpcomingExercises.removeAll()
            allUpcomingExercisesForTodayTarget.removeAll()
            
            // Her seçili egzersiz için yaklaşan zamanları hesapla
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
            
            // Önce zamanları sırala
            allUpcomingExercises = allUpcomingExercises
                .filter { $0.1 > now }
                .sorted { $0.1 < $1.1 }
            
            // Egzersizler arasında minimum 5 dakikalık aralık olmasını sağla
            if !allUpcomingExercises.isEmpty {
                var adjustedExercises: [(Exercise, Date)] = []
                adjustedExercises.append(allUpcomingExercises[0]) // İlk egzersizi olduğu gibi ekle
                
                // Diğer egzersizleri kontrol et ve gerekirse ayarla
                for i in 1..<allUpcomingExercises.count {
                    let previousExercise = adjustedExercises.last!
                    let currentExercise = allUpcomingExercises[i]
                    
                    // İki egzersiz arasındaki farkı hesapla (saniye cinsinden)
                    let timeDifference = currentExercise.1.timeIntervalSince(previousExercise.1)
                    
                    if timeDifference < 300 { // 5 dakika = 300 saniye
                        // Eğer fark 5 dakikadan azsa, önceki egzersizden 5 dakika sonrasına ayarla
                        let newTime = previousExercise.1.addingTimeInterval(300)
                        adjustedExercises.append((currentExercise.0, newTime))
                    } else {
                        // Fark zaten 5 dakikadan fazlaysa olduğu gibi ekle
                        adjustedExercises.append(currentExercise)
                    }
                }
                
                // Ayarlanmış zamanları geri ata
                allUpcomingExercises = adjustedExercises
            }
            
            // Hesaplama durumunu ve son seçili egzersizleri güncelle
            exerciseTimesCalculated = true
            lastSelectedExerciseIds = currentSelectedExerciseIds
        } else {
            print("Egzersiz zamanları korunuyor, sadece geçmiş zamanlar filtreleniyor...")
            
            // Sadece geçmiş zamanları filtrele
            allUpcomingExercises = allUpcomingExercises
                .filter { $0.1 > now }
        }
        
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
                    id: UUID().uuidString, // Bildirim/gösterim için unique ID
                    exerciseId: pair.0.id, // Egzersizin kendi ID'si
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
                id: UUID().uuidString, // Bildirim/gösterim için unique ID
                exerciseId: pair.0.id, // Egzersizin kendi ID'si
                name: pair.0.name,
                scheduledTime: pair.1,
                time: "", // Bildirimler için time string'e gerek yok
                duration: pair.0.durationSeconds.map { $0 / 60 } ?? 0,
                iconName: pair.0.categories.first?.icon ?? "figure.walk"
            )
        }
        notificationManager.rescheduleNotifications(exercises: allNotifications)
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
    
    // MARK: - UserExercisesServiceDelegate
    func userExercisesDidChange() {
        Task {
            // Kullanıcı egzersizleri değiştiğinde, exerciseTimesCalculated'i sıfırla
            // böylece zamanlar yeniden hesaplanacak
            exerciseTimesCalculated = false
            await loadExercises()
        }
    }
    
    func exerciseCompleted() {
        Task {
            await loadExercises()
        }
    }
}

// MARK: - Models
struct UpcomingExercise: Identifiable, Codable {
    let id: String // Bildirim/gösterim için unique ID
    let exerciseId: String // Egzersizin kendi ID'si
    let name: String
    let scheduledTime: Date
    let time: String
    let duration: Int
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case id, exerciseId, name, scheduledTime, time, duration, iconName
    }
}