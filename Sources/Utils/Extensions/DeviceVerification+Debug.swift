#if DEBUG
import Foundation

extension MockDeviceVerificationService {
    /// Test için cihaz doğrulama sonucunu değiştir
    static func setDeviceValidation(isValid: Bool) {
        shouldReturnValidDevice = isValid
    }
    
    /// Test için DeviceCheck desteğini değiştir
    static func setDeviceCheckSupport(isSupported: Bool) {
        isDeviceCheckSupported = isSupported
    }
    
    /// Tüm test durumlarını sıfırla
    static func resetToDefaults() {
        shouldReturnValidDevice = true
        isDeviceCheckSupported = true
    }
}
#endif 