import Foundation
import DeviceCheck
import FirebaseAuth
import FirebaseFirestore

enum DeviceVerificationError: LocalizedError {
    case deviceNotSupported
    case tokenGenerationFailed
    case validationFailed
    
    var errorDescription: String? {
        switch self {
        case .deviceNotSupported:
            return "Bu cihaz güvenlik doğrulamasını desteklemiyor."
        case .tokenGenerationFailed:
            return "Cihaz doğrulama işlemi başarısız oldu."
        case .validationFailed:
            return "Cihaz doğrulanamadı. Lütfen gerçek bir iOS cihazı kullandığınızdan emin olun."
        }
    }
}

protocol DeviceVerificationServiceProtocol {
    func verifyDevice() async throws -> Bool
}

#if DEBUG
// Test için kullanılacak mock servis
final class MockDeviceVerificationService: DeviceVerificationServiceProtocol {
    // Test için device validation sonucunu kontrol edebileceğimiz flagler
    static var shouldReturnValidDevice: Bool = true
    static var isDeviceCheckSupported: Bool = true
    
    func verifyDevice() async throws -> Bool {
        // Önce DeviceCheck desteğini kontrol et
        guard MockDeviceVerificationService.isDeviceCheckSupported else {
            throw DeviceVerificationError.deviceNotSupported
        }
        
        // Test için yapay gecikme ekleyelim
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye
        return MockDeviceVerificationService.shouldReturnValidDevice
    }
}
#endif

final class DeviceVerificationService: DeviceVerificationServiceProtocol {
    private let dcDevice: DCDevice
    private let db: Firestore
    private var lastVerificationDate: Date?
    private var currentTask: Task<Bool, Error>?
    
    init() {
        self.dcDevice = DCDevice.current
        self.db = Firestore.firestore()
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    func verifyDevice() async throws -> Bool {
        // Cihaz desteğini kontrol et
        guard dcDevice.isSupported else {
            throw DeviceVerificationError.deviceNotSupported
        }
        
        // Token oluştur
        let token = try await dcDevice.generateToken()
        
        // Token'ı doğrula ve kaydet
        try await validateAndSaveToken(token)
        
        return true
    }
    
    private func validateAndSaveToken(_ token: Data) async throws {
        let deviceData: [String: Any] = [
            "token": token.base64EncodedString(),
            "timestamp": FieldValue.serverTimestamp(),
            "platform": "iOS",
            "version": UIDevice.current.systemVersion
        ]
        
        let docRef = db.collection("verifiedDevices").document()
        try await docRef.setData(deviceData)
    }
} 