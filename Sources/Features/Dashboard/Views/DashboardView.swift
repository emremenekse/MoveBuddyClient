import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Günlük Özet Kartı
                    DailySummaryCard(viewModel: viewModel)
                    
                    // Yaklaşan Egzersizler
                    UpcomingExercisesCard(viewModel: viewModel)
                    
                    // İstatistik Özeti
                    StatisticsSummaryCard(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("Merhaba, \(viewModel.userName)!")
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}

// MARK: - Supporting Views
private struct DailySummaryCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Günlük Özet")
                .font(.headline)
            
            HStack(spacing: 24) {
                // Tamamlanan egzersizler
                StatView(
                    title: "Tamamlanan",
                    value: "\(viewModel.completedToday)",
                    subtitle: "egzersiz",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                // Harcanan süre
                StatView(
                    title: "Toplam Süre",
                    value: "\(viewModel.completedMinutesToday)",
                    subtitle: "dakika",
                    icon: "timer",
                    color: .blue
                )
                
                // Kalan egzersizler (günlük hedef)
                StatView(
                    title: "Günlük Hedef",
                    value: "\(viewModel.remainingToday)",
                    subtitle: "kalan",
                    icon: "target",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct UpcomingExercisesCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Yaklaşan Egzersizler")
                .font(.headline)
            
            if viewModel.upcomingExercises.isEmpty {
                Text("Bugün için planlanmış egzersiz yok")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.upcomingExercises) { exercise in
                    HStack {
                        Image(systemName: exercise.iconName)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                                .font(.subheadline)
                            Text(exercise.time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(exercise.duration) dk")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct StatisticsSummaryCard: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Haftalık İstatistikler")
                .font(.headline)
            
            HStack(spacing: 24) {
                StatView(
                    title: "Toplam",
                    value: "\(viewModel.weeklyTotal)",
                    subtitle: "egzersiz",
                    icon: "sum",
                    color: .purple
                )
                
                StatView(
                    title: "Ortalama",
                    value: "\(viewModel.weeklyAverage)",
                    subtitle: "günlük",
                    icon: "chart.bar.fill",
                    color: .blue
                )
                
                StatView(
                    title: "En İyi",
                    value: "\(viewModel.weeklyBest)",
                    subtitle: "egzersiz",
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct StatView: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppViewModel.shared)
} 