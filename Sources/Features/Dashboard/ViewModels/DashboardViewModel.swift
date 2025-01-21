import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var completedExercises: Int = 0
    @Published var remainingExercises: Int = 0
    @Published var totalMinutes: Int = 0
    @Published var upcomingExercises: [UpcomingExercise] = []
    @Published var weeklyTotal: Int = 0
    @Published var weeklyAverage: Double = 0
    @Published var weeklyBest: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let initialSetupService: InitialSetupService
    
    init(initialSetupService: InitialSetupService = .shared) {
        self.initialSetupService = initialSetupService
        Task {
            await loadUserInfo()
            await loadDummyData()
        }
        setupSubscriptions()
    }
    
    func refreshData() async {
        // TODO: Gerçek veri yenileme işlemleri burada yapılacak
        await loadDummyData()
    }
    
    private func loadUserInfo() async {
        guard let userInfo = try? await Task { try initialSetupService.getUserInfo() }.value else { return }
        userName = userInfo.name
    }
    
    private func setupSubscriptions() {
        // TODO: Gerekli subscription'lar burada kurulacak
    }
    
    private func loadDummyData() async {
        // Günlük özet için dummy data
        completedExercises = 3
        remainingExercises = 2
        totalMinutes = 45
        
        // Yaklaşan egzersizler için dummy data
        upcomingExercises = [
            UpcomingExercise(id: UUID(), name: "Omuz Egzersizi", time: "14:30", duration: 15, iconName: "figure.walk"),
            UpcomingExercise(id: UUID(), name: "Boyun Egzersizi", time: "16:00", duration: 10, iconName: "figure.walk"),
        ]
        
        // Haftalık istatistikler için dummy data
        weeklyTotal = 15
        weeklyAverage = 2.5
        weeklyBest = 4
    }
}

// MARK: - Models
struct UpcomingExercise: Identifiable {
    let id: UUID
    let name: String
    let time: String
    let duration: Int
    let iconName: String
} 