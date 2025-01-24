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
    
    private var cancellables = Set<AnyCancellable>()
    private var initialSetupService: InitialSetupService
    private var exercisesService: ExercisesService
    private var userExercisesService: UserExercisesService
    private var workSchedule: WorkSchedule?
    private let notificationManager = ExerciseNotificationManager.shared
    
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
        
        print("📱 Tüm egzersizler:", exercises.map { "id: \($0.id), name: \($0.name)" })
        print("✅ Seçili egzersizler:", selectedExercises.map { "exerciseId: \($0.exerciseId), interval: \($0.reminderInterval)" })
        
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
            print("⚠️ Work schedule bulunamadı")
            return
        }
        
        // Her egzersiz için gelecek 5 zamanı al ve birleştir
        var allUpcomingExercises: [(Exercise, Date)] = []
        
        for selectedExercise in selectedExercises {
            guard let exercise = exercises.first(where: { $0.id == selectedExercise.exerciseId }) else {
                continue
            }
            
            let nextTimes = selectedExercise.reminderInterval.nextOccurrences(from: now, workSchedule: schedule)
            let exerciseTimes = nextTimes.map { (exercise, $0) }
            allUpcomingExercises.append(contentsOf: exerciseTimes)
        }
        
        // Tüm zamanları sırala ve ilk 5'ini al
        upcomingExercises = allUpcomingExercises
            .filter { $0.1 > now }
            .sorted { $0.1 < $1.1 }
            .prefix(5)
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
            
        // Yaklaşan egzersizler için bildirimleri planla
        print("🔔 Bildirim planlanacak egzersizler:", upcomingExercises.map { "id: \($0.id), name: \($0.name), time: \($0.scheduledTime)" })
        notificationManager.scheduleExerciseNotifications(exercises: upcomingExercises)
        
        // Haftalık istatistikler için gerçek data
        weeklyTotal = selectedExercises.count
        weeklyAverage = Double(selectedExercises.count) / 7.0
        weeklyBest = completedExercises // Şimdilik tamamlanan sayısını kullanıyoruz
    }
    
    private let calendar = Calendar.current
    
    private func setupSubscriptions() {
        // TODO: Gerekli subscription'lar burada kurulacak
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