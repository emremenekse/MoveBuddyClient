import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overallStatsCard
                topUsersCard
                popularExercisesCard
            }
            .padding()
        }
        .task {
            await viewModel.fetchStatistics()
        }
        .refreshable {
            await viewModel.fetchStatistics()
        }
    }
    
    private var overallStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overall Statistics")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Users",
                    value: "\(viewModel.totalUsersCount)",
                    systemImage: "person.3"
                )
                
                StatCard(
                    title: "Completions",
                    value: "\(viewModel.totalCompletionsCount)",
                    systemImage: "checkmark.circle"
                )
            }
            
            Text("Last Updated: \(viewModel.lastUpdated)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private var topUsersCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Users")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(viewModel.getTopUsers(), id: \.userId) { user in
                HStack {
                    Text(user.userId)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(user.completionCount) completions")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                if user.userId != viewModel.getTopUsers().last?.userId {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private var popularExercisesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Exercises")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(viewModel.getMostPopularExercises(), id: \.name) { exercise in
                HStack {
                    Text(exercise.name)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(exercise.count) times")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                if exercise.name != viewModel.getMostPopularExercises().last?.name {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    StatisticsView()
}