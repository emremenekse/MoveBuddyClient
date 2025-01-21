import Foundation

struct InitialUserInfo: Codable {
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

enum WeekDay: String, Codable, CaseIterable {
    case monday = "Pazartesi"
    case tuesday = "Salı"
    case wednesday = "Çarşamba"
    case thursday = "Perşembe"
    case friday = "Cuma"
    case saturday = "Cumartesi"
    case sunday = "Pazar"
}

enum WorkspaceType: String, Codable, CaseIterable {
    case office = "Ofis"
    case home = "Ev"
    case coworking = "CoWorking Alan"
}

enum ExerciseType: String, Codable, CaseIterable {
    case stretching = "Esneme"
    case lightFitness = "Hafif Fitness"
    case posture = "Dolaşım/Postür"
    case eyeExercises = "Göz Egzersizleri"
} 