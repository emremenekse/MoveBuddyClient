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
    }
    
    func isExerciseSelected(_ exerciseId: String) -> Bool {
        selectedExercises.contains { $0.exerciseId == exerciseId }
    }
    
    // MARK: - Private Methods
    private func loadSelectedExercises() {
        guard let data = defaults.data(forKey: selectedExercisesKey),
              let exercises = try? JSONDecoder().decode([UserSelectedExercise].self, from: data) else {
            selectedExercises = []
            return
        }
        
        selectedExercises = exercises
    }
    
    private func saveSelectedExercises() {
        guard let data = try? JSONEncoder().encode(selectedExercises) else { return }
        defaults.set(data, forKey: selectedExercisesKey)
    }
} 