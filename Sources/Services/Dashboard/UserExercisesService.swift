import Foundation
import Combine

@MainActor
final class UserExercisesService {
    // MARK: - Singleton
    static let shared = UserExercisesService()
    
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let selectedExercisesKey = "selectedExercises"
    private let completedExercisesKey = "completedExercises"
    
    @Published private(set) var selectedExercises: [UserSelectedExercise] = []
    @Published private(set) var completedExercises: [CompletedExercise] = []
    
    // Değişiklikleri dinlemek için publisher'lar
    var exercisesPublisher: AnyPublisher<[UserSelectedExercise], Never> {
        $selectedExercises.eraseToAnyPublisher()
    }
    
    var completedExercisesPublisher: AnyPublisher<[CompletedExercise], Never> {
        $completedExercises.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    private init() {
        loadSelectedExercises()
        loadCompletedExercises()
    }
    
    // MARK: - Public Methods
    func addExercise(_ exerciseId: String, reminderInterval: ReminderInterval) {
        let exercise = UserSelectedExercise(
            exerciseId: exerciseId,
            reminderInterval: reminderInterval
        )
        
        selectedExercises.append(exercise)
        saveSelectedExercises()
    }
    
    func removeExercise(withId id: String) {
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
    
    func completeExercise(_ exerciseId: String) {
        let completed = CompletedExercise(exerciseId: exerciseId)
        completedExercises.append(completed)
        saveCompletedExercises()
    }
    
    // MARK: - Private Methods
    private func loadSelectedExercises() {
        guard let data = defaults.data(forKey: selectedExercisesKey),
              let exercises = try? JSONDecoder().decode([UserSelectedExercise].self, from: data) else {
            
            selectedExercises = []
            return
        }
        
        selectedExercises = exercises
        print(" Yüklenen egzersizler:", exercises.count)
    }
    
    private func saveSelectedExercises() {
        guard let data = try? JSONEncoder().encode(selectedExercises) else {
            return
        }
        defaults.set(data, forKey: selectedExercisesKey)
    }
    
    private func loadCompletedExercises() {
        guard let data = defaults.data(forKey: completedExercisesKey),
              let exercises = try? JSONDecoder().decode([CompletedExercise].self, from: data) else {
            completedExercises = []
            return
        }
        completedExercises = exercises
    }
    
    private func saveCompletedExercises() {
        guard let data = try? JSONEncoder().encode(completedExercises) else { return }
        defaults.set(data, forKey: completedExercisesKey)
    }
}