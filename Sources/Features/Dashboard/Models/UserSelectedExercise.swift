import Foundation

struct UserSelectedExercise: Codable, Identifiable {
    let id: String  // UUID olarak oluşturulacak
    let exerciseId: String  // Firestore'daki egzersizin ID'si
    let reminderInterval: ReminderInterval
    
    init(exerciseId: String, reminderInterval: ReminderInterval) {
        self.id = UUID().uuidString
        self.exerciseId = exerciseId
        self.reminderInterval = reminderInterval
    }
} 