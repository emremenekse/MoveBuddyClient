import FirebaseFirestore

struct AppLog: Codable {
    @DocumentID var id: String?
    let message: String
    let timestamp: Date
    let deviceId: String
    let logLevel: String
    let userId: String?
}



@MainActor
final class Logger {
    // MARK: - Singleton
    static let shared = Logger()
    
    // MARK: - Properties
    private let firebaseService: FirebaseService
    private var db: Firestore { Firestore.firestore() }
    
    private init() {
        self.firebaseService = FirebaseService.shared
    }
    
    
    func log(_ message: String, level: String = "INFO") {
        let logData: [String: Any] = [
            "message": message,
            "level": level,
            "timestamp": Date(),
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        ]
        
        db.collection("logs").addDocument(data: logData) { error in
            if let error = error {
                print("❌ CRITICAL LOG ERROR: \(error.localizedDescription)")
            } else {
                print("✅ Log başarıyla kaydedildi: \(message)")
            }
        }
    }
}