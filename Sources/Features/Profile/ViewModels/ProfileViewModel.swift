import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name: String = ""
    @Published var nickname: String = ""
    @Published var workspaceTypes: Set<WorkspaceType> = []
    @Published var exercisePreferences: Set<ExerciseType> = []
    @Published var workSchedule = WorkSchedule(workDays: [:])
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private var originalUserInfo: InitialUserInfo?
    private var cancellables = Set<AnyCancellable>()
    private let initialSetupService: InitialSetupService
    private let userExercisesService: UserExercisesService
    private let nicknameKey = "user_nickname"
    
    // MARK: - Computed Properties
    var displayNickname: String {
        // Son _ karakterinden sonraki kısmı sil
        let components = nickname.components(separatedBy: "_")
        if components.count >= 2 {
            return components[0...1].joined(separator: "_")
        }
        return nickname
    }
    
    var hasChanges: Bool {
        guard let originalUserInfo = originalUserInfo else { return false }
        
        return name != originalUserInfo.name ||
        workspaceTypes != originalUserInfo.workspaceType ||
        exercisePreferences != originalUserInfo.exercisePreferences ||
        workSchedule.workDays != originalUserInfo.workSchedule.workDays
    }
    
    // MARK: - Initialization
    nonisolated init(initialSetupService: InitialSetupService = .shared) {
        self.initialSetupService = initialSetupService
        self.userExercisesService = .shared
        
        Task { @MainActor in
            await self.loadUserInfo()
            await self.loadOrGenerateNickname()
        }
    }
    
    private func loadOrGenerateNickname() async {
        do {
            // Önce KeyChain'den userId'yi al
            if let userId = try? KeychainManager.shared.getUserId(),
               // Firestore'dan kullanıcı bilgilerini kontrol et
               let userData = try? await UserService.shared.getUserData(userId: userId) {
                // Firestore'da kayıtlı nickname varsa onu kullan
                self.nickname = userData.nickname
                // UserDefaults'a da kaydet
                UserDefaults.standard.set(userData.nickname, forKey: nicknameKey)
                return
            }
            
            // Eğer buraya geldiysek ya userId yok ya da Firestore'da kayıt yok
            // UserDefaults'tan nickname'i kontrol et
            if let savedNickname = UserDefaults.standard.string(forKey: nicknameKey) {
                self.nickname = savedNickname
                
                // Eğer userId varsa, Firestore'a da kaydet
                if let userId = try? KeychainManager.shared.getUserId() {
                    try? await UserService.shared.saveUserData(userId: userId, nickname: savedNickname)
                }
            } else {
                // Yeni nickname oluştur
                let newNickname = NicknameGenerator.shared.generateNickname()
                self.nickname = newNickname
                UserDefaults.standard.set(newNickname, forKey: nicknameKey)
                
                // Eğer userId varsa, Firestore'a da kaydet
                if let userId = try? KeychainManager.shared.getUserId() {
                    try? await UserService.shared.saveUserData(userId: userId, nickname: newNickname)
                }
            }
        } catch {
            print("Nickname yüklenirken hata: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func saveChanges() async {
        do {
            guard let userId = try? KeychainManager.shared.getUserId() else {
                throw ProfileError.userIdNotFound
            }
            
            let userInfo = InitialUserInfo(
                userId: userId,
                name: name,
                workspaceType: workspaceTypes,
                exercisePreferences: exercisePreferences,
                workSchedule: workSchedule
            )
            
            try await initialSetupService.saveUserInfo(userInfo)
            originalUserInfo = userInfo
            name = userInfo.name
            workspaceTypes = userInfo.workspaceType
            exercisePreferences = userInfo.exercisePreferences
            workSchedule = userInfo.workSchedule
            
            // Değişiklikler kaydedildiğinde delegate'i tetikle
            userExercisesService.delegate?.userExercisesDidChange()
            
            showError = false
            errorMessage = ""
        } catch {
            showError = true
            errorMessage = error.localizedDescription
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
