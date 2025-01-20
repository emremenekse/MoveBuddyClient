import Foundation
import Combine

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isLoginSuccessful: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        AuthenticationService.shared.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .error(let error):
                    self?.isLoginSuccessful = false
                    ErrorHandlingService.shared.handle(error)
                case .authenticated:
                    self?.isLoginSuccessful = true
                case .unauthenticated, .authenticating:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func signIn() async {
        do {
            // Validasyon kontrolleri
            guard !email.isEmpty else {
                throw ValidationError.emptyField("E-posta")
            }
            
            guard !password.isEmpty else {
                throw ValidationError.emptyField("Şifre")
            }
            
            try await AuthenticationService.shared.signIn(email: email, password: password)
            
        } catch {
            ErrorHandlingService.shared.handle(error)
            isLoginSuccessful = false
        }
    }
    
    func signInWithApple() async {
        // TODO: Apple ile giriş implementasyonu
    }
    
    func signInWithGoogle() async {
        // TODO: Google ile giriş implementasyonu
    }
} 