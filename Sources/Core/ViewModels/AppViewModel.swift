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
    
    @Published var currentFlow: AppFlow = .onboarding
    @Published var currentUser: User?
    
    private var cancellables = Set<AnyCancellable>()
    private let initialSetupService: InitialSetupService
    
    private init(initialSetupService: InitialSetupService = .shared) {
        self.initialSetupService = initialSetupService
        determineCurrentFlow()
    }
    
    private func setupSubscriptions() async {
        // Auth state değişikliklerini dinle
        await withCheckedContinuation { continuation in
            AuthenticationService.shared.authStatePublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    guard let self = self else { return }
                    
                    if self.isDebugMode {
                        // Debug modda her zaman OnBoarding'de kal
                        self.currentFlow = .onboarding
                        return
                    }
                    
                    switch state {
                    case .authenticated(let user):
                        self.currentUser = user
                        if self.initialSetupService.hasCompletedInitialSetup {
                            self.currentFlow = .main
                        } else {
                            self.currentFlow = .initialSetup
                        }
                    case .unauthenticated:
                        self.currentUser = nil
                        if self.hasCompletedOnboarding {
                            if self.initialSetupService.hasCompletedInitialSetup {
                                self.currentFlow = .main
                            } else {
                                self.currentFlow = .initialSetup
                            }
                        } else {
                            self.currentFlow = .onboarding
                        }
                    case .error:
                        self.currentUser = nil
                        if self.hasCompletedOnboarding {
                            if self.initialSetupService.hasCompletedInitialSetup {
                                self.currentFlow = .main
                            } else {
                                self.currentFlow = .initialSetup
                            }
                        } else {
                            self.currentFlow = .onboarding
                        }
                    case .authenticating:
                        break // Loading durumunda flow değişmez
                    }
                }
                .store(in: &self.cancellables)
            
            continuation.resume()
        }
    }
    
    func determineCurrentFlow() {
        if !hasCompletedOnboarding {
            currentFlow = .onboarding
        } else if !initialSetupService.hasCompletedInitialSetup {
            currentFlow = .initialSetup
        } else {
            currentFlow = .main
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        currentFlow = .initialSetup
    }
    
    func completeInitialSetup() {
        currentFlow = .main
    }
    
    func clearUserInfo() {
        initialSetupService.clearUserInfo()
        determineCurrentFlow()
    }
}

// MARK: - Models
enum AppFlow {
    case onboarding
    case initialSetup
    case main
}

// MARK: - View Extensions
extension AppFlow {
    @ViewBuilder
    var view: some View {
        switch self {
        case .onboarding:
            OnboardingView()
        case .initialSetup:
            InitialSetupView()
        case .main:
            MainTabView()
        }
    }
} 