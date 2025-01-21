import Foundation
import FirebaseFirestore

@MainActor
final class ExercisesService {
    // MARK: - Singleton
    static let shared = ExercisesService()
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    private let exercisesCollection = "exercises"
    
    @Published private(set) var exercises: [Exercise] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Initialization
    private init() {
    }
    
    // MARK: - Public Methods
    func fetchExercises() async {
        isLoading = true
        error = nil
        
        do {
            let snapshot = try await db.collection(exercisesCollection).getDocuments()
            
            // Eğer veri yoksa dummy dataları yükle
            if snapshot.documents.isEmpty {
                try await loadDummyData()
                // Dummy dataları yükledikten sonra tekrar fetch et
                let newSnapshot = try await db.collection(exercisesCollection).getDocuments()
                exercises = try newSnapshot.documents.compactMap { document in
                    return try document.data(as: Exercise.self)
                }
            } else {
                exercises = try snapshot.documents.compactMap { document in
                    return try document.data(as: Exercise.self)
                }
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func loadDummyData() async throws {
        
        // Batch write kullanarak tüm dummy dataları tek seferde yükle
        let batch = db.batch()
        
        for exercise in Exercise.dummyData {
            let document = db.collection(exercisesCollection).document(exercise.id)
            try batch.setData(from: exercise, forDocument: document)
        }
        
        try await batch.commit()
    }
}
    