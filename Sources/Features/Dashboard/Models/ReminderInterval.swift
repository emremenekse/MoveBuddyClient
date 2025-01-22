import Foundation

enum ReminderInterval: Int, CaseIterable, Identifiable, Codable {
    case fifteenMinutes = 15
    case thirtyMinutes = 30
    case oneHour = 60
    case twoHours = 120
    case threeHours = 180
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .fifteenMinutes: return "15 dakika"
        case .thirtyMinutes: return "30 dakika"
        case .oneHour: return "1 saat"
        case .twoHours: return "2 saat"
        case .threeHours: return "3 saat"
        }
    }
} 