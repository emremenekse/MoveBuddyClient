import SwiftUI

struct MainTabView: View {
    @StateObject private var appViewModel = AppViewModel.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "house.fill")
                }
                .tag(0)
            
            ExercisesView()
                .tabItem {
                    Label("Egzersizler", systemImage: "figure.walk")
                }
                .tag(1)
            
            StatisticsView()
                .tabItem {
                    Label("İstatistikler", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
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