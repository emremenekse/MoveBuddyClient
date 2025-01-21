import Foundation

enum TabItem: Int, CaseIterable {
    case dashboard
    case exercises
    case statistics
    case profile
    
    var title: String {
        switch self {
        case .dashboard:
            return "Ana Sayfa"
        case .exercises:
            return "Egzersizler"
        case .statistics:
            return "İstatistikler"
        case .profile:
            return "Profil"
        }
    }
    
    var iconName: String {
        switch self {
        case .dashboard:
            return "house.fill"
        case .exercises:
            return "figure.walk"
        case .statistics:
            return "chart.bar.fill"
        case .profile:
            return "person.fill"
        }
    }
} 