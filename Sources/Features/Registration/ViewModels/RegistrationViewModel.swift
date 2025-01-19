import Foundation
import Combine
import FirebaseAuth

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirmation: String = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isRegistrationSuccessful: Bool = false
    
    private let registrationService: AuthenticationServiceProtocol
    private let errorHandler: ErrorHandlingService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        registrationService: AuthenticationServiceProtocol,
        errorHandler: ErrorHandlingService
    ) {
        self.registrationService = registrationService
        self.errorHandler = errorHandler
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        registrationService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                Task { @MainActor in
                    switch state {
                    case .authenticating:
                        self?.isLoading = true
                    case .error(let error):
                        self?.isLoading = false
                        self?.isRegistrationSuccessful = false
                        self?.errorHandler.handle(error)
                    case .authenticated:
                        break
                    case .unauthenticated:
                        self?.isLoading = false
                        self?.isRegistrationSuccessful = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func register() async {
        do {
            isLoading = true
            
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
            
            try await registrationService.register(email: email, password: password)
            isRegistrationSuccessful = true
            
        } catch {
            errorHandler.handle(error)
            isRegistrationSuccessful = false
        }
        
        isLoading = false
    }
} 