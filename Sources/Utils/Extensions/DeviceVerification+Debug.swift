#if DEBUG
import Foundation

extension MockDeviceVerificationService {
    /// Test için cihaz doğrulama sonucunu değiştir
    static func setDeviceValidation(isValid: Bool) {
        shouldReturnValidDevice = isValid
        print("🔍 Device validation set to: \(isValid ? "Valid" : "Invalid")")
    }
    
    /// Test için DeviceCheck desteğini değiştir
    static func setDeviceCheckSupport(isSupported: Bool) {
        isDeviceCheckSupported = isSupported
        print("📱 DeviceCheck support set to: \(isSupported ? "Supported" : "Not Supported")")
    }
    
    /// Tüm test durumlarını sıfırla
    static func resetToDefaults() {
        shouldReturnValidDevice = true
        isDeviceCheckSupported = true
        print("🔄 Device verification settings reset to defaults")
    }
}
#endif 