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
                StatView(title: "Tamamlanan", value: "\(viewModel.completedExercises)", icon: "checkmark.circle.fill")
                StatView(title: "Kalan", value: "\(viewModel.remainingExercises)", icon: "clock.fill")
                StatView(title: "Toplam Süre", value: "\(viewModel.totalMinutes) dk", icon: "timer")
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
                StatView(title: "Toplam", value: "\(viewModel.weeklyTotal)", icon: "sum")
                StatView(title: "Ortalama", value: "\(viewModel.weeklyAverage)/gün", icon: "chart.bar.fill")
                StatView(title: "En İyi", value: "\(viewModel.weeklyBest)", icon: "star.fill")
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
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppViewModel.shared)
} 