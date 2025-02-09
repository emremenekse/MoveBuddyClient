import Foundation

enum ProfileError: LocalizedError {
    case userIdNotFound
    case nicknameGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .userIdNotFound:
            return "Kullanıcı kimliği bulunamadı"
        case .nicknameGenerationFailed:
            return "Takma ad oluşturulurken bir hata oluştu"
        }
    }
}
