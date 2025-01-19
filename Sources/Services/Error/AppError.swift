import Foundation

// MARK: - Base Error Protocol
protocol AppErrorProtocol: LocalizedError {
    var title: String { get }
    var message: String { get }
    var code: Int { get }
    var errorType: ErrorType { get }
}

// MARK: - Error Types
enum ErrorType {
    case network
    case authentication
    case validation
    case server
    case client
    case unknown
}

// MARK: - Base Error Implementation
struct AppError: AppErrorProtocol {
    let title: String
    let message: String
    let code: Int
    let errorType: ErrorType
    let underlyingError: Error?
    
    var errorDescription: String? { message }
    
    init(
        title: String,
        message: String,
        code: Int = 0,
        errorType: ErrorType = .unknown,
        underlyingError: Error? = nil
    ) {
        self.title = title
        self.message = message
        self.code = code
        self.errorType = errorType
        self.underlyingError = underlyingError
    }
}

// MARK: - Network Errors
enum NetworkError: AppErrorProtocol {
    case noInternet
    case timeout
    case serverError(Int)
    case invalidResponse
    case invalidData
    
    var title: String {
        switch self {
        case .noInternet: return "İnternet Bağlantısı Yok"
        case .timeout: return "Zaman Aşımı"
        case .serverError: return "Sunucu Hatası"
        case .invalidResponse: return "Geçersiz Yanıt"
        case .invalidData: return "Geçersiz Veri"
        }
    }
    
    var message: String {
        switch self {
        case .noInternet: return "Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin."
        case .timeout: return "İşlem zaman aşımına uğradı. Lütfen tekrar deneyin."
        case .serverError(let code): return "Sunucu hatası (\(code)). Lütfen daha sonra tekrar deneyin."
        case .invalidResponse: return "Sunucudan geçersiz yanıt alındı."
        case .invalidData: return "Alınan veri işlenemedi."
        }
    }
    
    var code: Int {
        switch self {
        case .noInternet: return -1009
        case .timeout: return -1001
        case .serverError(let code): return code
        case .invalidResponse: return -1002
        case .invalidData: return -1003
        }
    }
    
    var errorType: ErrorType { .network }
}

// MARK: - Authentication Errors
enum AuthError: AppErrorProtocol {
    case invalidCredentials
    case accountNotFound
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case tooManyAttempts
    case notAuthenticated
    case sessionExpired
    case deviceVerificationFailed
    
    var title: String {
        switch self {
        case .invalidCredentials: return "Geçersiz Kimlik"
        case .accountNotFound: return "Hesap Bulunamadı"
        case .emailAlreadyInUse: return "E-posta Kullanımda"
        case .weakPassword: return "Zayıf Şifre"
        case .invalidEmail: return "Geçersiz E-posta"
        case .tooManyAttempts: return "Çok Fazla Deneme"
        case .notAuthenticated: return "Oturum Açılmamış"
        case .sessionExpired: return "Oturum Süresi Doldu"
        case .deviceVerificationFailed: return "Cihaz Doğrulaması Başarısız"
        }
    }
    
    var message: String {
        switch self {
        case .invalidCredentials: return "E-posta veya şifre hatalı."
        case .accountNotFound: return "Bu e-posta adresiyle kayıtlı bir hesap bulunamadı."
        case .emailAlreadyInUse: return "Bu e-posta adresi zaten kullanımda."
        case .weakPassword: return "Şifre çok zayıf. Lütfen en az 6 karakter kullanın."
        case .invalidEmail: return "Geçerli bir e-posta adresi girin."
        case .tooManyAttempts: return "Çok fazla deneme yaptınız. Lütfen bir süre bekleyin."
        case .notAuthenticated: return "Bu işlem için oturum açmanız gerekiyor."
        case .sessionExpired: return "Oturum süreniz doldu. Lütfen tekrar giriş yapın."
        case .deviceVerificationFailed: return "Cihaz doğrulaması başarısız oldu."
        }
    }
    
    var code: Int {
        switch self {
        case .invalidCredentials: return 401
        case .accountNotFound: return 404
        case .emailAlreadyInUse: return 409
        case .weakPassword: return 400
        case .invalidEmail: return 400
        case .tooManyAttempts: return 429
        case .notAuthenticated: return 401
        case .sessionExpired: return 440
        case .deviceVerificationFailed: return 403
        }
    }
    
    var errorType: ErrorType { .authentication }
}

// MARK: - Validation Errors
enum ValidationError: AppErrorProtocol {
    case emptyField(String)
    case invalidFormat(String)
    case custom(String)
    
    var title: String {
        switch self {
        case .emptyField: return "Eksik Bilgi"
        case .invalidFormat: return "Geçersiz Format"
        case .custom: return "Doğrulama Hatası"
        }
    }
    
    var message: String {
        switch self {
        case .emptyField(let field): return "\(field) alanı boş bırakılamaz."
        case .invalidFormat(let field): return "\(field) formatı geçersiz."
        case .custom(let message): return message
        }
    }
    
    var code: Int { 422 }
    var errorType: ErrorType { .validation }
} 