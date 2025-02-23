import Foundation
import FirebaseCore

final class FirebaseService {
    static let shared = FirebaseService()
    
    private var isConfigured = false
    
    private init() {}
    
    func configure() {
        guard !isConfigured else {
            return
        }
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        isConfigured = true
    }
}