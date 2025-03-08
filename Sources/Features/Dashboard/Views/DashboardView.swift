import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Daily Summary Card
                    DailySummaryCard(viewModel: viewModel)
                    
                    // Upcoming Exercises
                    UpcomingExercisesCard(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("dashboard.greeting".localized(with: viewModel.userName))
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
            Text("dashboard.daily.summary".localized)
                .font(.headline)
            
            HStack(spacing: 24) {
                // Completed exercises
                StatView(
                    title: "dashboard.completed".localized,
                    value: "\(viewModel.completedToday)",
                    subtitle: "dashboard.exercises".localized,
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                // Time spent
                StatView(
                    title: "dashboard.total.time".localized,
                    value: "\(viewModel.completedMinutesToday)",
                    subtitle: "dashboard.minutes".localized,
                    icon: "timer",
                    color: .blue
                )
                
                // Remaining exercises (daily goal)
                StatView(
                    title: "dashboard.daily.goal".localized,
                    value: "\(viewModel.remainingToday)",
                    subtitle: "dashboard.remaining".localized,
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
            Text("dashboard.upcoming.exercises".localized)
                .font(.headline)
            
            if viewModel.upcomingExercises.isEmpty {
                Text("dashboard.no.planned.exercises".localized)
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
                        
                        Text("dashboard.duration.minutes".localized(with: exercise.duration))
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