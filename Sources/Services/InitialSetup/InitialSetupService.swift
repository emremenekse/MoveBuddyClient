import Foundation

@MainActor
final class InitialSetupService {
    static let shared = InitialSetupService()
    
    private let userDefaults = UserDefaults.standard
    private let userInfoKey = "initialUserInfo"
    private let setupCompletedKey = "hasCompletedInitialSetup"
    
    private init() {}
    
    var hasCompletedInitialSetup: Bool {
        userDefaults.bool(forKey: setupCompletedKey)
    }
    
    func saveUserInfo(_ userInfo: InitialUserInfo) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(userInfo)
        userDefaults.set(data, forKey: userInfoKey)
        userDefaults.set(true, forKey: setupCompletedKey)
    }
    
    func getUserInfo() throws -> InitialUserInfo? {
        guard let data = userDefaults.data(forKey: userInfoKey) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(InitialUserInfo.self, from: data)
    }
    
    func clearUserInfo() {
        userDefaults.removeObject(forKey: userInfoKey)
        userDefaults.removeObject(forKey: setupCompletedKey)
    }
} 