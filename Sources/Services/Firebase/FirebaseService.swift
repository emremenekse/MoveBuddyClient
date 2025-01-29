import Foundation
import FirebaseCore

final class FirebaseService {
    static let shared = FirebaseService()
    
    private var isConfigured = false
    
    private init() {}
    
    func configure() {
        guard !isConfigured else {
            print("⚠️ Firebase is already configured")
            return
        }
        
        print("🔥 Configuring Firebase...")
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        isConfigured = true
        print("✅ Firebase configuration completed")
    }
}