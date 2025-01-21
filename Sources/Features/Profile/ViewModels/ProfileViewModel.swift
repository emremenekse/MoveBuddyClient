import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var workspaceTypes: Set<WorkspaceType> = []
    @Published var exercisePreferences: Set<ExerciseType> = []
    @Published var workSchedule = WorkSchedule(workDays: [:])
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private var originalUserInfo: InitialUserInfo?
    private var cancellables = Set<AnyCancellable>()
    private let initialSetupService: InitialSetupService
    private let authenticationService: AuthenticationService
    
    // MARK: - Computed Properties
    var hasChanges: Bool {
        guard let originalUserInfo = originalUserInfo else { return false }
        
        return name != originalUserInfo.name ||
        workspaceTypes != originalUserInfo.workspaceType ||
        exercisePreferences != originalUserInfo.exercisePreferences ||
        workSchedule.workDays != originalUserInfo.workSchedule.workDays
    }
    
    // MARK: - Initialization
    nonisolated init(initialSetupService: InitialSetupService = .shared,
         authenticationService: AuthenticationService = .shared) {
        self.initialSetupService = initialSetupService
        self.authenticationService = authenticationService
        
        Task { @MainActor in
            await self.loadUserInfo()
        }
    }
    
    // MARK: - Public Methods
    func saveChanges() async {
        do {
            let userInfo = InitialUserInfo(
                name: name,
                workspaceType: workspaceTypes,
                exercisePreferences: exercisePreferences,
                workSchedule: workSchedule
            )
            
            try await initialSetupService.saveUserInfo(userInfo)
            originalUserInfo = userInfo
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        Task { @MainActor in
            do {
                try await authenticationService.signOut()
            } catch {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadUserInfo() async {
        guard let userInfo = try? await initialSetupService.getUserInfo() else {
            showError = true
            errorMessage = "Kullanıcı bilgileri yüklenemedi"
            return
        }
        
        originalUserInfo = userInfo
        
        // Update UI
        name = userInfo.name
        workspaceTypes = userInfo.workspaceType
        exercisePreferences = userInfo.exercisePreferences
        workSchedule = userInfo.workSchedule
    }
}
