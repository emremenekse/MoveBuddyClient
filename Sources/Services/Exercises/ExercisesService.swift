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
            // Fetching exercises from Firestore
            let snapshot = try await db.collection(exercisesCollection).getDocuments()
            // Eğer veri yoksa dummy dataları yükle
            if snapshot.documents.isEmpty {
                // No exercises found in Firestore, loading dummy data
                try await loadDummyData()
                // Dummy dataları yükledikten sonra tekrar fetch et
                // Fetching exercises again after loading dummy data
                let newSnapshot = try await db.collection(exercisesCollection).getDocuments()
                
                if newSnapshot.documents.isEmpty {
                    // Still no exercises found after loading dummy data
                    // Fallback to dummy data if Firestore still fails
                    exercises = Exercise.dummyData
                } else {
                    // Found exercises after loading dummy data
                    exercises = try convertSnapshotToExercises(newSnapshot)
                }
            } else {
                // Found existing exercises in Firestore
                exercises = try convertSnapshotToExercises(snapshot)
            }
        } catch {
            // Error occurred while fetching exercises
            self.error = error
            // Fallback to dummy data if there's an error
            exercises = Exercise.dummyData
        }
        
        isLoading = false
    }
    
    // Helper method to convert Firestore documents to Exercise objects
    private func convertSnapshotToExercises(_ snapshot: QuerySnapshot) throws -> [Exercise] {
        return try snapshot.documents.compactMap { document in
            let data = document.data()
            
            // Extract data from Firestore document
            guard let id = data["id"] as? String,
                  let nameKey = data["nameKey"] as? String,
                  let descriptionKey = data["descriptionKey"] as? String,
                  let categoryStrings = data["categories"] as? [String],
                  let environmentStrings = data["environments"] as? [String] else {
                // Missing required fields for document
                return nil
            }
            
            // Convert string arrays to enum arrays
            let categories = categoryStrings.compactMap { ExerciseCategory(rawValue: $0) }
            let environments = environmentStrings.compactMap { ExerciseEnvironment(rawValue: $0) }
            
            // Optional fields
            let stepKeys = data["stepKeys"] as? [String]
            let durationSeconds = data["durationSeconds"] as? Int
            
            var difficulty: Difficulty? = nil
            if let difficultyString = data["difficulty"] as? String {
                difficulty = Difficulty(rawValue: difficultyString)
            }
            
            var videoURL: URL? = nil
            if let videoURLString = data["videoURL"] as? String {
                videoURL = URL(string: videoURLString)
            }
            
            var imageURL: URL? = nil
            if let imageURLString = data["imageURL"] as? String {
                imageURL = URL(string: imageURLString)
            }
            return Exercise(
                id: id,
                nameKey: nameKey,
                descriptionKey: descriptionKey,
                stepKeys: stepKeys,
                categories: categories,
                environments: environments,
                durationSeconds: durationSeconds,
                difficulty: difficulty,
                videoURL: videoURL,
                imageURL: imageURL
            )
        }
    }
    
    // MARK: - Private Methods
    private func loadDummyData() async throws {
        
        // Exercise data debug information removed
        
        do {
            // Attempting to save exercise data to Firestore
            
            // Batch write kullanarak tüm dummy dataları tek seferde yükle
            let batch = db.batch()
            
            for exercise in Exercise.dummyData {
                // Preparing document for exercise
                let document = db.collection(exercisesCollection).document(exercise.id)
                
                // Create a dictionary manually to ensure proper encoding
                let data: [String: Any] = [
                    "id": exercise.id,
                    "nameKey": exercise.nameKey,
                    "descriptionKey": exercise.descriptionKey,
                    "stepKeys": exercise.stepKeys as Any,
                    "categories": exercise.categories.map { $0.rawValue },
                    "environments": exercise.environments.map { $0.rawValue },
                    "durationSeconds": exercise.durationSeconds as Any,
                    "difficulty": exercise.difficulty?.rawValue as Any,
                    "videoURL": exercise.videoURL?.absoluteString as Any,
                    "imageURL": exercise.imageURL?.absoluteString as Any
                ]
                
                batch.setData(data, forDocument: document)
            }
            
            // Committing batch to Firestore
            try await batch.commit()
            // Successfully saved exercise data
        } catch {
            // Error saving exercise data to Firestore
            throw error
        }
    }
}
    