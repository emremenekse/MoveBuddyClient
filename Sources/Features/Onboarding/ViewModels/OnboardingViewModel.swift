import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var showSignIn: Bool = false
    @Published var showRegistration: Bool = false
    
    var items: [OnboardingItem] {
        OnboardingItem.items
    }
    
    func nextPage() {
        if currentPage < items.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    func startApp() {
        showRegistration = true
    }
    
    func goToSignIn() {
        showSignIn = true
    }
    
    func skipOnboarding() {
        showSignIn = true
    }
} 