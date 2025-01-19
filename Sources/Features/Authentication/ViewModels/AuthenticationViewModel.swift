import Foundation

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private let appViewModel: AppViewModel
    private let authService: AuthenticationServiceProtocol
    
    init(appViewModel: AppViewModel, authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.appViewModel = appViewModel
        self.authService = authService
    }
    
    func signInWithApple() {
        // TODO: Apple ile giriş implementasyonu
    }
    
    func signInWithGoogle() {
        // TODO: Google ile giriş implementasyonu
    }
} 