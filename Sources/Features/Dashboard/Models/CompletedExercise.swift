import Foundation

struct CompletedExercise: Codable, Identifiable {
    let id: String // Tamamlama kaydının unique ID'si
    let exerciseId: String // Hangi egzersizin tamamlandığı
    let completedAt: Date
    
    init(exerciseId: String, completedAt: Date = Date()) {
        self.id = "\(exerciseId)_\(Int(completedAt.timeIntervalSince1970))" // exerciseId_timestamp formatında unique ID
        self.exerciseId = exerciseId // Egzersizin ID'si
        self.completedAt = completedAt
    }
}
