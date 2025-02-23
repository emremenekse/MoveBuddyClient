import Foundation
import Combine
import FirebaseFirestore

protocol UserExercisesServiceDelegate: AnyObject {
    func userExercisesDidChange()
    func exerciseCompleted()
}

// Opsiyonel metod için extension
extension UserExercisesServiceDelegate {
    func exerciseCompleted() {}
}

@MainActor
final class UserExercisesService {
    // MARK: - Singleton
    static let shared = UserExercisesService()
    
    // MARK: - Properties
    private let defaults = UserDefaults.standard
    private let selectedExercisesKey = "selectedExercises"
    private let completedExercisesKey = "completedExercises"
    private let db = Firestore.firestore()
    // Artık deviceId yerine userId kullanıyoruz
    private let exercisesService: ExercisesService
    
    weak var delegate: UserExercisesServiceDelegate?
    
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
    private init(exercisesService: ExercisesService = .shared) {
        self.exercisesService = exercisesService
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
    
    func removeExercisesForDay(_ weekDay: WeekDay) {
        // Bildirimleri yeniden planla
        Task {
            // Delegate'e haber ver
            await MainActor.run {
                print("Egzersizler yeniden planlanıyorAAA")
                delegate?.userExercisesDidChange()
            }
        }
    }
    
    func isExerciseSelected(_ exerciseId: String) -> Bool {
        selectedExercises.contains { $0.exerciseId == exerciseId }
    }
    
    func completeExercise(_ exerciseId: String) {
        let completed = CompletedExercise(exerciseId: exerciseId)
        completedExercises.append(completed)
        saveCompletedExercises()
        
        // Firebase'e kaydet
        Task {
            await saveCompletedExerciseToFirestore(completed)
        }
        
        Task {
            await MainActor.run {
                delegate?.exerciseCompleted()
            }
        }
    }

    func skipExercise() {
        Task {
            await MainActor.run {
                delegate?.exerciseCompleted()
            }
        }
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
    
    private func saveCompletedExerciseToFirestore(_ completed: CompletedExercise) async {
        // Egzersiz bilgilerini al
        guard let exercise = exercisesService.exercises.first(where: { $0.id == completed.exerciseId }) else {
            print("❌ Egzersiz bulunamadı:", completed.exerciseId)
            return
        }
        
        guard let userId = try? KeychainManager.shared.getUserId() else {
            print("❌ UserId bulunamadı")
            return
        }
        
        // UserService'den nickname'i al
        let userData = try? await UserService.shared.getUserData(userId: userId)
        
        let data: [String: Any] = [
            "userId": userId,
            "nickname": userData?.nickname ?? "",
            "exerciseId": completed.exerciseId,
            "notificationId": completed.id,
            "completedAt": completed.completedAt,
            "duration": exercise.durationSeconds ?? 0,
            "name": exercise.name,
            "categories": exercise.categories.map { $0.rawValue },
            "difficulty": exercise.difficulty?.rawValue ?? "unknown"
        ]
        
        do {
            // Her kullanıcı için bir document oluştur ve içine userId'yi ekle
            try await db.collection("completedExercises").document(userId).setData(["userId": userId], merge: true)
            
            // Altına completions ekle
            let userRef = db.collection("completedExercises").document(userId).collection("completions")
            try await userRef.document(completed.id).setData(data)
        } catch {
            print("❌ Firebase kayıt hatası:", error.localizedDescription)
        }
    }
}