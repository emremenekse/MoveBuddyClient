import Foundation

struct RegistrationModel {
    var email: String = ""
    var password: String = ""
    var passwordConfirmation: String = ""
    
    func validate() throws {
        // Email validasyonu
        guard !email.isEmpty else { 
            throw ValidationError.emptyField("Email")
        }
        guard email.contains("@") else { 
            throw ValidationError.invalidFormat("Email")
        }
        
        // Şifre validasyonu
        guard !password.isEmpty else {
            throw ValidationError.emptyField("Şifre")
        }
        guard password.count >= 6 else { 
            throw ValidationError.custom("Şifre en az 6 karakter olmalıdır")
        }
        guard password == passwordConfirmation else { 
            throw ValidationError.custom("Şifreler eşleşmiyor")
        }
    }
} 