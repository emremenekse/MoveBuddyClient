import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case stretching       // Esneme
    case lightFitness     // Hafif fitness
    case postureCirculation  // Dolaşım / Postür
    case eyeCare          // Göz egzersizi
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .stretching: return "Esneme"
        case .lightFitness: return "Hafif Fitness"
        case .postureCirculation: return "Dolaşım / Postür"
        case .eyeCare: return "Göz Egzersizi"
        }
    }
    
    var icon: String {
        switch self {
        case .stretching: return "figure.mixed.cardio"
        case .lightFitness: return "figure.walk"
        case .postureCirculation: return "figure.stand"
        case .eyeCare: return "eye"
        }
    }
}

enum ExerciseEnvironment: String, Codable, CaseIterable, Identifiable {
    case office
    case home
    case coWorking
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .office: return "Ofis"
        case .home: return "Ev"
        case .coWorking: return "Co-Working"
        }
    }
    
    var icon: String {
        switch self {
        case .office: return "building.2"
        case .home: return "house"
        case .coWorking: return "building"
        }
    }
}

enum Difficulty: String, Codable, CaseIterable, Identifiable {
    case beginner
    case intermediate
    case advanced
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .beginner: return "Başlangıç"
        case .intermediate: return "Orta"
        case .advanced: return "İleri"
        }
    }
}

struct Exercise: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let steps: [String]?
    let categories: [ExerciseCategory]
    let environments: [ExerciseEnvironment]
    let durationSeconds: Int?
    let difficulty: Difficulty?
    let videoURL: URL?
    let imageURL: URL?
    
    var formattedDuration: String? {
        guard let seconds = durationSeconds else { return nil }
        return "\(seconds / 60) dk"
    }
}

extension Exercise {
    static var dummyData: [Exercise] {
        [
            Exercise(
                id: "1",
                name: "Boyun Rotasyonu",
                description: "Boyun kaslarını esnetmek ve rahatlatmak için yapılan temel bir egzersiz.",
                steps: [
                    "Dik bir şekilde oturun",
                    "Başınızı yavaşça sağa çevirin",
                    "5 saniye bekleyin",
                    "Başınızı merkeze getirin",
                    "Aynı hareketi sola tekrarlayın"
                ],
                categories: [.stretching, .postureCirculation],
                environments: [.office, .home, .coWorking],
                durationSeconds: 180,
                difficulty: .beginner,
                videoURL: URL(string: "https://www.youtube.com/watch?v=XxEDk9G5D0k"),
                imageURL: URL(string: "https://raw.githubusercontent.com/emremenekse/MoveBuddy/main/Resources/Images/neck-rotation.jpg")
            ),
            Exercise(
                id: "2",
                name: "Göz Dinlendirme",
                description: "Ekrana uzun süre bakmaktan yorulan gözler için rahatlatıcı egzersiz.",
                steps: [
                    "Ekrandan uzağa bakın",
                    "20-20-20 kuralını uygulayın",
                    "Gözlerinizi ovuşturmadan dinlendirin"
                ],
                categories: [.eyeCare],
                environments: [.office, .home, .coWorking],
                durationSeconds: 60,
                difficulty: .beginner,
                videoURL: URL(string: "https://www.youtube.com/watch?v=W10j2fL0hy0"),
                imageURL: URL(string: "https://raw.githubusercontent.com/emremenekse/MoveBuddy/main/Resources/Images/eye-rest.jpg")
            ),
            Exercise(
                id: "3",
                name: "Masa Başı Squats",
                description: "Oturma süresini azaltmak ve kan dolaşımını artırmak için basit egzersiz.",
                steps: [
                    "Ayağa kalkın",
                    "Hafifçe çömelin",
                    "5 tekrar yapın"
                ],
                categories: [.lightFitness],
                environments: [.office, .coWorking],
                durationSeconds: 120,
                difficulty: .intermediate,
                videoURL: URL(string: "https://www.youtube.com/watch?v=YaXPRqUwItQ"),
                imageURL: URL(string: "https://raw.githubusercontent.com/emremenekse/MoveBuddy/main/Resources/Images/desk-squats.jpg")
            )
        ]
    }
} 