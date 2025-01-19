import Foundation

struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

extension OnboardingItem {
    static let items: [OnboardingItem] = [
        OnboardingItem(
            title: "Hoş Geldiniz",
            description: "MoveBuddy ile daha aktif bir yaşama adım atın.",
            imageName: "figure.walk"
        ),
        OnboardingItem(
            title: "Kişiselleştirilmiş Öneriler",
            description: "Size özel hareket önerileri ve hatırlatıcılar ile aktif kalın.",
            imageName: "person.fill.checkmark"
        ),
        OnboardingItem(
            title: "Video Rehberler",
            description: "Detaylı video rehberler ile hareketleri doğru şekilde yapın.",
            imageName: "play.circle.fill"
        )
    ]
} 