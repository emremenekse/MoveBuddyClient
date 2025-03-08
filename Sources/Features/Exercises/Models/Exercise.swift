import Foundation

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case stretching
    case lightFitness
    case postureCirculation
    case eyeCare
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .stretching: return "exercise.category.stretching".localized
        case .lightFitness: return "exercise.category.light.fitness".localized
        case .postureCirculation: return "exercise.category.posture.circulation".localized
        case .eyeCare: return "exercise.category.eye.care".localized
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
        case .office: return "exercise.environment.office".localized
        case .home: return "exercise.environment.home".localized
        case .coWorking: return "exercise.environment.coworking".localized
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
        case .beginner: return "exercise.difficulty.beginner".localized
        case .intermediate: return "exercise.difficulty.intermediate".localized
        case .advanced: return "exercise.difficulty.advanced".localized
        }
    }
}

struct Exercise: Identifiable, Codable {
    let id: String
    let nameKey: String  // Localization key for name
    let descriptionKey: String  // Localization key for description
    let stepKeys: [String]?  // Localization keys for steps
    let categories: [ExerciseCategory]
    let environments: [ExerciseEnvironment]
    let durationSeconds: Int?
    let difficulty: Difficulty?
    let videoURL: URL?
    let imageURL: URL?
    
    // Localized properties (not stored in Firestore)
    var name: String {
        return nameKey.localized
    }
    
    var description: String {
        return descriptionKey.localized
    }
    
    var steps: [String]? {
        return stepKeys?.map { $0.localized }
    }
    
    var formattedDuration: String? {
        guard let seconds = durationSeconds else { return nil }
        return "exercise.duration.minutes".localized(with: seconds / 60)
    }
    
    // Custom Codable implementation to ensure proper encoding for Firestore
    enum CodingKeys: String, CodingKey {
        case id, nameKey, descriptionKey, stepKeys, categories, environments, durationSeconds, difficulty, videoURL, imageURL
    }
}

extension Exercise {
    static var dummyData: [Exercise] {
        [
            Exercise(
                id: "1",
                nameKey: "exercise.1.name",
                descriptionKey: "exercise.1.description",
                stepKeys: [
                    "exercise.1.step.1",
                    "exercise.1.step.2",
                    "exercise.1.step.3",
                    "exercise.1.step.4",
                    "exercise.1.step.5"
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
                nameKey: "exercise.2.name",
                descriptionKey: "exercise.2.description",
                stepKeys: [
                    "exercise.2.step.1",
                    "exercise.2.step.2",
                    "exercise.2.step.3"
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
                nameKey: "exercise.3.name",
                descriptionKey: "exercise.3.description",
                stepKeys: [
                    "exercise.3.step.1",
                    "exercise.3.step.2",
                    "exercise.3.step.3"
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