import SwiftUI
import Combine

// Global exception handler function
private func handleUncaughtException(_ exception: NSException) {
    Task { @MainActor in
        ErrorHandlingService.shared.handle(
            AppError(
                title: "Beklenmeyen Hata",
                message: exception.description,
                errorType: .unknown
            )
        )
    }
}

@MainActor
final class ErrorHandlingService: ObservableObject {
    // MARK: - Properties
    @Published private(set) var currentError: AppErrorProtocol?
    @Published private(set) var showError: Bool = false
    @Published private(set) var errorConfig: ErrorConfig?
    
    static let shared = ErrorHandlingService()
    private var errorSubject = PassthroughSubject<AppErrorProtocol, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Error Stream
    func errorStream() -> AsyncStream<AppErrorProtocol> {
        AsyncStream { continuation in
            let cancellable = errorSubject
                .sink { error in
                    continuation.yield(error)
                }
            
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        setupErrorHandling()
    }
    
    // MARK: - Error Handling Setup
    private func setupErrorHandling() {
        // Global error stream'ini dinle
        errorSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleError(error, config: .default)
            }
            .store(in: &cancellables)
        
        // Uncaught exception handler'ı ayarla
        NSSetUncaughtExceptionHandler(handleUncaughtException)
    }
    
    // MARK: - Public Methods
    func handle(_ error: Error, config: ErrorConfig = .default) {
        if let appError = error as? AppErrorProtocol {
            handleError(appError, config: config)
        } else {
            // Firebase veya diğer servis hatalarını dönüştür
            let convertedError = convertError(error)
            handleError(convertedError, config: config)
        }
    }
    
    func dismissError() {
        withAnimation {
            currentError = nil
            showError = false
            errorConfig = nil
        }
    }
    
    // MARK: - Private Methods
    private func handleError(_ error: AppErrorProtocol, config: ErrorConfig) {
        withAnimation {
            currentError = error
            errorConfig = config
            showError = true
        }
        
    }
    
    private func convertError(_ error: Error) -> AppErrorProtocol {
        // Firebase Auth hataları
        if let nsError = error as NSError? {
            switch nsError.code {
            case 17020: // Network error
                return NetworkError.noInternet
            case 17010: // Invalid credentials
                return AuthError.invalidCredentials
            case 17008: // Invalid email
                return AuthError.invalidEmail
            case 17026: // Password is weak
                return AuthError.weakPassword
            case 17007: // Email already exists
                return AuthError.emailAlreadyInUse
            case 17011: // Too many requests
                return AuthError.tooManyAttempts
            default:
                return AppError(
                    title: "Hata",
                    message: error.localizedDescription,
                    code: nsError.code,
                    errorType: .unknown,
                    underlyingError: error
                )
            }
        }
        
        // Diğer hatalar için genel bir dönüşüm
        return AppError(
            title: "Hata",
            message: error.localizedDescription,
            errorType: .unknown,
            underlyingError: error
        )
    }
}

// MARK: - Error Configuration
struct ErrorConfig {
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let showIcon: Bool
    let primaryAction: (() -> Void)?
    let secondaryAction: (() -> Void)?
    
    static let `default` = ErrorConfig(
        primaryButtonTitle: "Tamam",
        secondaryButtonTitle: nil,
        showIcon: true,
        primaryAction: nil,
        secondaryAction: nil
    )
    
    static func custom(
        primaryButtonTitle: String = "Tamam",
        secondaryButtonTitle: String? = nil,
        showIcon: Bool = true,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) -> ErrorConfig {
        ErrorConfig(
            primaryButtonTitle: primaryButtonTitle,
            secondaryButtonTitle: secondaryButtonTitle,
            showIcon: showIcon,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        )
    }
}

// MARK: - View Modifier
struct ErrorAlert: ViewModifier {
    @ObservedObject var errorService: ErrorHandlingService
    
    func body(content: Content) -> some View {
        content.overlay {
            if errorService.showError,
               let error = errorService.currentError,
               let config = errorService.errorConfig {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        ErrorView(
                            error: error,
                            primaryButtonTitle: config.primaryButtonTitle,
                            secondaryButtonTitle: config.secondaryButtonTitle,
                            showIcon: config.showIcon,
                            primaryAction: {
                                config.primaryAction?()
                                errorService.dismissError()
                            },
                            secondaryAction: config.secondaryAction
                        )
                        .padding(.horizontal, 24)
                    }
                    // Error overlay için sabit bir z-index belirliyoruz
                    .zIndex(1000)
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func handleErrors() -> some View {
        modifier(ErrorAlert(errorService: ErrorHandlingService.shared))
    }
} 