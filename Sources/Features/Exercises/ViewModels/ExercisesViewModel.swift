import Foundation
import Combine

@MainActor
final class ExercisesViewModel: ObservableObject {
    // MARK: - Properties
    private let exercisesService: ExercisesService
    private let userExercisesService: UserExercisesService
    
    // MARK: - Published Properties
    @Published private(set) var exercises: [Exercise] = []
    @Published private(set) var selectedCategory: ExerciseCategory?
    @Published private(set) var selectedEnvironment: ExerciseEnvironment?
    @Published private(set) var searchText = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            var matches = true
            
            // Kategori filtresi
            if let selectedCategory = selectedCategory {
                matches = matches && exercise.categories.contains(selectedCategory)
            }
            
            // Ortam filtresi
            if let selectedEnvironment = selectedEnvironment {
                matches = matches && exercise.environments.contains(selectedEnvironment)
            }
            
            // Arama filtresi
            if !searchText.isEmpty {
                matches = matches && (
                    exercise.name.localizedCaseInsensitiveContains(searchText) ||
                    exercise.description.localizedCaseInsensitiveContains(searchText)
                )
            }
            
            return matches
        }
        .sorted { $0.name < $1.name }
    }
    
    // MARK: - Initialization
    init(
        exercisesService: ExercisesService = .shared,
        userExercisesService: UserExercisesService = .shared
    ) {
        self.exercisesService = exercisesService
        self.userExercisesService = userExercisesService
        
        // UserDefaults'taki verileri yazdır
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "selectedExercises"),
           let exercises = try? JSONDecoder().decode([UserSelectedExercise].self, from: data) {
        }
        
        setupBindings()
        Task {
            await loadExercises()
        }
    }
    
    // MARK: - Public Methods
    func selectCategory(_ category: ExerciseCategory?) {
        selectedCategory = category
    }
    
    func selectEnvironment(_ environment: ExerciseEnvironment?) {
        selectedEnvironment = environment
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    func isExerciseSelected(_ exerciseId: String) -> Bool {
        userExercisesService.isExerciseSelected(exerciseId)
    }
    
    func addExercise(_ exerciseId: String, reminderInterval: ReminderInterval) {
        userExercisesService.addExercise(exerciseId, reminderInterval: reminderInterval)
    }
    
    func removeExercise(_ exerciseId: String) {
        userExercisesService.removeExercise(withId: exerciseId)
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        exercisesService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        exercisesService.$error
            .map { $0?.localizedDescription }
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
        
        exercisesService.$exercises
            .assign(to: \.exercises, on: self)
            .store(in: &cancellables)
            
        // UserExercisesService değişikliklerini dinle
        userExercisesService.$selectedExercises
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadExercises() async {
        await exercisesService.fetchExercises()
    }
} 