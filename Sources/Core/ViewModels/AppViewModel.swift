import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    // MARK: - Singleton
    static let shared = AppViewModel()
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("isDebugMode") var isDebugMode: Bool = false
    
    @Published var currentFlow: AppFlow = .determining
    @Published var currentUser: User?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupSubscriptions()
        determineInitialFlow()
    }
    
    private func setupSubscriptions() {
        // Auth state değişikliklerini dinle
        AuthenticationService.shared.authStatePublisher
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
        } else if AuthenticationService.shared.isAuthenticated {
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