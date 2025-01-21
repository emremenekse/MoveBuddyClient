import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: TabItem = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // TODO: Implement DashboardView
            Text("Dashboard")
                .tabItem {
                    Label(TabItem.dashboard.title,
                          systemImage: TabItem.dashboard.iconName)
                }
                .tag(TabItem.dashboard)
            
            // TODO: Implement ExercisesView
            Text("Exercises")
                .tabItem {
                    Label(TabItem.exercises.title,
                          systemImage: TabItem.exercises.iconName)
                }
                .tag(TabItem.exercises)
            
            // TODO: Implement StatisticsView
            Text("Statistics")
                .tabItem {
                    Label(TabItem.statistics.title,
                          systemImage: TabItem.statistics.iconName)
                }
                .tag(TabItem.statistics)
            
            ProfileView()
                .tabItem {
                    Label(TabItem.profile.title,
                          systemImage: TabItem.profile.iconName)
                }
                .tag(TabItem.profile)
        }
        .tint(.blue) // TabBar rengi
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel.shared)
} 