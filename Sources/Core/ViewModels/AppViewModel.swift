import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("isDebugMode") var isDebugMode: Bool = false
    
    @Published var currentFlow: AppFlow = .determining
    @Published var currentUser: User?
    
    // AppViewModel tüm authentication özelliklerine ihtiyaç duyduğu için
    // AuthenticationServiceProtocol'ü kullanıyoruz (SignIn + Registration + SignOut)
    let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        setupSubscriptions()
        determineInitialFlow()
    }
    
    private func setupSubscriptions() {
        // Auth state değişikliklerini dinle
        authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if self?.isDebugMode == true {
                    // Debug modda her zaman OnBoarding'de kal
                    self?.currentFlow = .onboarding
                    return
                }
                
                switch state {
                case .authenticated(let user):
                    self?.currentUser = user
                    self?.currentFlow = .main
                case .unauthenticated:
                    self?.currentUser = nil
                    if self?.hasCompletedOnboarding == true {
                        self?.currentFlow = .authentication
                    } else {
                        self?.currentFlow = .onboarding
                    }
                case .error:
                    self?.currentUser = nil
                    if self?.hasCompletedOnboarding == true {
                        self?.currentFlow = .authentication
                    } else {
                        self?.currentFlow = .onboarding
                    }
                case .authenticating:
                    break // Loading durumunda flow değişmez
                }
            }
            .store(in: &cancellables)
    }
    
    enum AppFlow {
        case determining
        case onboarding
        case authentication
        case main
    }
    
    func determineInitialFlow() {
        if isDebugMode {
            // Debug modda her zaman OnBoarding'den başla
            currentFlow = .onboarding
            return
        }
        
        if !hasCompletedOnboarding {
            currentFlow = .onboarding
        } else if authService.isAuthenticated {
            currentFlow = .main
        } else {
            currentFlow = .authentication
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentFlow = .authentication
    }
    
    func completeAuthentication() {
        currentFlow = .main
    }
} 