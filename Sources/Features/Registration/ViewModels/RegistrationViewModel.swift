import Foundation
import Combine
import FirebaseAuth

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var errorMessage: String?
    @Published var isRegistrationSuccessful: Bool = false
    
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
                    self?.isRegistrationSuccessful = false
                    ErrorHandlingService.shared.handle(error)
                case .authenticated:
                    self?.isRegistrationSuccessful = true
                case .unauthenticated, .authenticating:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func register() async {
        do {
            // Validasyon kontrolleri
            guard !email.isEmpty else {
                throw ValidationError.emptyField("E-posta")
            }
            
            guard !password.isEmpty else {
                throw ValidationError.emptyField("Şifre")
            }
            
            guard password == passwordConfirmation else {
                throw ValidationError.custom("Şifreler eşleşmiyor")
            }
            
            guard password.count >= 6 else {
                throw ValidationError.custom("Şifre en az 6 karakter olmalıdır")
            }
            
            try await AuthenticationService.shared.register(email: email, password: password)
            
        } catch {
            ErrorHandlingService.shared.handle(error)
            isRegistrationSuccessful = false
        }
    }
} 