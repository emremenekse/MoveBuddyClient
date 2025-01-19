import Foundation
import FirebaseAuth

enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case error(AuthError)
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.unauthenticated, .unauthenticated),
             (.authenticating, .authenticating):
            return true
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser.uid == rhsUser.uid
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

enum RegistrationStep: Int, CaseIterable {
    case emailPassword
    case basicInfo
    case preferences
    case completed
    
    var title: String {
        switch self {
        case .emailPassword: return "Hesap Bilgileri"
        case .basicInfo: return "Kişisel Bilgiler"
        case .preferences: return "Tercihler"
        case .completed: return "Tamamlandı"
        }
    }
} 