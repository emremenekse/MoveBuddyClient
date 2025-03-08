import Foundation

struct InitialUserInfo: Codable {
    let userId: String
    let name: String
    let workspaceType: Set<WorkspaceType>
    let exercisePreferences: Set<ExerciseType>
    let workSchedule: WorkSchedule
    
    var isComplete: Bool {
        !name.isEmpty && 
        !workspaceType.isEmpty && 
        !exercisePreferences.isEmpty &&
        workSchedule.isValid
    }
}

// MARK: - Supporting Types
struct WorkSchedule: Codable, Equatable {
    struct WorkDay: Codable, Equatable {
        let startHour: Int // 0-23 arası
        let endHour: Int   // 0-23 arası
    }
    
    var workDays: [WeekDay: WorkDay]
    
    var isValid: Bool {
        !workDays.isEmpty && workDays.allSatisfy { 
            $0.value.startHour >= 0 && 
            $0.value.startHour < $0.value.endHour && 
            $0.value.endHour <= 23
        }
    }
}

enum WeekDay: String, Codable, CaseIterable, Identifiable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .monday: return "weekday.monday".localized
        case .tuesday: return "weekday.tuesday".localized
        case .wednesday: return "weekday.wednesday".localized
        case .thursday: return "weekday.thursday".localized
        case .friday: return "weekday.friday".localized
        case .saturday: return "weekday.saturday".localized
        case .sunday: return "weekday.sunday".localized
        }
    }
    
    // Custom decoder to handle old format with Turkish raw values
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "monday", "Pazartesi": self = .monday
        case "tuesday", "Salı": self = .tuesday
        case "wednesday", "Çarşamba": self = .wednesday
        case "thursday", "Perşembe": self = .thursday
        case "friday", "Cuma": self = .friday
        case "saturday", "Cumartesi": self = .saturday
        case "sunday", "Pazar": self = .sunday
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown WeekDay: \(rawValue)")
        }
    }
}

enum WorkspaceType: String, Codable, CaseIterable, Identifiable {
    case office
    case home
    case coworking
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .office: return "workspace.office".localized
        case .home: return "workspace.home".localized
        case .coworking: return "workspace.coworking".localized
        }
    }
    
    // Custom decoder to handle old format with Turkish raw values
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "office", "Ofis": self = .office
        case "home", "Ev": self = .home
        case "coworking", "CoWorking Alan": self = .coworking
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown WorkspaceType: \(rawValue)")
        }
    }
}

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case stretching
    case lightFitness
    case posture
    case eyeExercises
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .stretching: return "exercise.type.stretching".localized
        case .lightFitness: return "exercise.type.light.fitness".localized
        case .posture: return "exercise.type.posture".localized
        case .eyeExercises: return "exercise.type.eye.exercises".localized
        }
    }
    
    // Custom decoder to handle old format with Turkish raw values
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "stretching", "Esneme": self = .stretching
        case "lightFitness", "Hafif Fitness": self = .lightFitness
        case "posture", "Dolaşım/Postür": self = .posture
        case "eyeExercises", "Göz Egzersizleri": self = .eyeExercises
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown ExerciseType: \(rawValue)")
        }
    }
} 