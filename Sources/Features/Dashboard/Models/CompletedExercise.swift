import Foundation

struct CompletedExercise: Codable, Identifiable {
    let id: String
    let exerciseId: String
    let completedAt: Date
    
    init(id: String = UUID().uuidString, exerciseId: String, completedAt: Date = Date()) {
        self.id = id
        self.exerciseId = exerciseId
        self.completedAt = completedAt
    }
}
