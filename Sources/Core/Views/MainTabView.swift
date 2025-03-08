import SwiftUI

struct MainTabView: View {
    @StateObject private var appViewModel = AppViewModel.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("tab.dashboard".localized, systemImage: "house.fill")
                }
                .tag(0)
            
            ExercisesView()
                .tabItem {
                    Label("tab.exercises".localized, systemImage: "figure.walk")
                }
                .tag(1)
            
            StatisticsView()
                .tabItem {
                    Label("tab.statistics".localized, systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("tab.profile".localized, systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel.shared)
} 