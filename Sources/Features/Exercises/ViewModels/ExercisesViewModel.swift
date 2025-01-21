import Foundation
import Combine

@MainActor
final class ExercisesViewModel: ObservableObject {
    // MARK: - Properties
    private let exercisesService: ExercisesService
    
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
    init(exercisesService: ExercisesService = .shared) {
        self.exercisesService = exercisesService
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
    }
    
    private func loadExercises() async {
        await exercisesService.fetchExercises()
    }
} 