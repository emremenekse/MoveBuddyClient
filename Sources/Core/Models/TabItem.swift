import Foundation

enum TabItem: Int, CaseIterable {
    case dashboard
    case exercises
    case statistics
    case profile
    
    var title: String {
        switch self {
        case .dashboard:
            return "tab.dashboard".localized
        case .exercises:
            return "tab.exercises".localized
        case .statistics:
            return "tab.statistics".localized
        case .profile:
            return "tab.profile".localized
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