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
            print("Fetching exercises from Firestore...")
            let snapshot = try await db.collection(exercisesCollection).getDocuments()
            
            // Eğer veri yoksa dummy dataları yükle
            if snapshot.documents.isEmpty {
                print("No exercises found in Firestore, loading dummy data...")
                try await loadDummyData()
                // Dummy dataları yükledikten sonra tekrar fetch et
                print("Fetching exercises again after loading dummy data...")
                let newSnapshot = try await db.collection(exercisesCollection).getDocuments()
                
                if newSnapshot.documents.isEmpty {
                    print("Still no exercises found after loading dummy data!")
                    // Fallback to dummy data if Firestore still fails
                    exercises = Exercise.dummyData
                } else {
                    print("Found \(newSnapshot.documents.count) exercises after loading dummy data")
                    exercises = try convertSnapshotToExercises(newSnapshot)
                }
            } else {
                print("Found \(snapshot.documents.count) existing exercises in Firestore")
                exercises = try convertSnapshotToExercises(snapshot)
            }
        } catch {
            print("Error fetching exercises: \(error)")
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
                print("Missing required fields for document \(document.documentID)")
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
        
        // Print exercise data for debugging
        print("\n==== EXERCISE DATA TO BE LOADED TO FIRESTORE ====")
        for exercise in Exercise.dummyData {
            print("\nExercise ID: \(exercise.id)")
            print("Name: \(exercise.name) (Key: \(exercise.nameKey))")
            print("Description: \(exercise.description) (Key: \(exercise.descriptionKey))")
            if let steps = exercise.steps, let stepKeys = exercise.stepKeys {
                print("Steps:")
                for (index, (step, key)) in zip(steps, stepKeys).enumerated() {
                    print("  \(index + 1). \(step) (Key: \(key))")
                }
            }
            print("Categories: \(exercise.categories.map { $0.title }.joined(separator: ", "))")
            print("Environments: \(exercise.environments.map { $0.title }.joined(separator: ", "))")
            if let difficulty = exercise.difficulty {
                print("Difficulty: \(difficulty.title)")
            }
            if let duration = exercise.formattedDuration {
                print("Duration: \(duration)")
            }
        }
        print("==== END OF EXERCISE DATA ====\n")
        
        do {
            print("Attempting to save exercise data to Firestore...")
            
            // Batch write kullanarak tüm dummy dataları tek seferde yükle
            let batch = db.batch()
            
            for exercise in Exercise.dummyData {
                print("Preparing document for exercise: \(exercise.id)")
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
            
            print("Committing batch to Firestore...")
            try await batch.commit()
            print("Successfully saved exercise data to Firestore!")
        } catch {
            print("Error saving exercise data to Firestore: \(error)")
            throw error
        }
    }
}
    