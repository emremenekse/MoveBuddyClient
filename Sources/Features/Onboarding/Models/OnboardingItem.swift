import Foundation

struct OnboardingItem: Identifiable {
    let id = UUID()
    let titleKey: String
    let descriptionKey: String
    let imageName: String
    
    var title: String {
        return titleKey.localized
    }
    
    var description: String {
        return descriptionKey.localized
    }
}

extension OnboardingItem {
    static let items: [OnboardingItem] = [
        OnboardingItem(
            titleKey: "onboarding.welcome.title",
            descriptionKey: "onboarding.welcome.description",
            imageName: "figure.walk"
        ),
        OnboardingItem(
            titleKey: "onboarding.personalized.title",
            descriptionKey: "onboarding.personalized.description",
            imageName: "person.fill.checkmark"
        ),
        OnboardingItem(
            titleKey: "onboarding.video.title",
            descriptionKey: "onboarding.video.description",
            imageName: "play.circle.fill"
        )
    ]
} 