import Foundation
import Combine

@MainActor
final class UserExercisesService {
    // MARK: - Singleton
    static let shared = UserExercisesService()
    
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let selectedExercisesKey = "selectedExercises"
    
    @Published private(set) var selectedExercises: [UserSelectedExercise] = []
    
    // MARK: - Initialization
    private init() {
        loadSelectedExercises()
    }
    
    // MARK: - Public Methods
    func addExercise(_ exerciseId: String, reminderInterval: ReminderInterval) {
        print("➕ Egzersiz ekleniyor:", exerciseId, "interval:", reminderInterval)
        let exercise = UserSelectedExercise(
            exerciseId: exerciseId,
            reminderInterval: reminderInterval
        )
        
        selectedExercises.append(exercise)
        saveSelectedExercises()
    }
    
    func removeExercise(withId id: String) {
        print("➖ Egzersiz siliniyor:", id)
        selectedExercises.removeAll { $0.exerciseId == id }
        saveSelectedExercises()
        
        // Egzersiz silindiğinde bildirimlerini de iptal et
        Task {
            await ExerciseNotificationManager.shared.cancelNotifications(for: id)
        }
    }
    
    func isExerciseSelected(_ exerciseId: String) -> Bool {
        selectedExercises.contains { $0.exerciseId == exerciseId }
    }
    
    // MARK: - Private Methods
    private func loadSelectedExercises() {
        print("📱 UserDefaults'tan egzersizler yükleniyor...")
        guard let data = defaults.data(forKey: selectedExercisesKey),
              let exercises = try? JSONDecoder().decode([UserSelectedExercise].self, from: data) else {
            print("❌ UserDefaults'ta kayıtlı egzersiz bulunamadı veya decode edilemedi")
            selectedExercises = []
            return
        }
        
        selectedExercises = exercises
        print("✅ Yüklenen egzersizler:", exercises)
    }
    
    private func saveSelectedExercises() {
        guard let data = try? JSONEncoder().encode(selectedExercises) else {
            print("❌ Egzersizler encode edilemedi")
            return
        }
        defaults.set(data, forKey: selectedExercisesKey)
        print("💾 Egzersizler kaydedildi:", selectedExercises)
        print(defaults)
    }
} 