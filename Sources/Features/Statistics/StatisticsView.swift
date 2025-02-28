import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
            VStack(spacing: 20) {
                // User Statistics Section
                userStatsSection
                
                // Weekly Stats Section
                weeklyStatsSection
                
                // Popular Exercises Section
                popularExercisesSection
                
                // All-Time Stats Section
                allTimeStatsSection
            }
            .padding()
            }
            .navigationTitle("Statistics")
        }
    }
    
    // MARK: - User Statistics Section
    private var userStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Statistics")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                // User Nickname
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                    Text("Welcome, \(viewModel.userNickname)")
                        .font(.headline)
                }
                
                // Weekly Stats
                statsCard(title: "Weekly Stats",
                         count: viewModel.weeklyCompletedExercises.count,
                         duration: viewModel.weeklyCompletedExercises.reduce(0) { $0 + $1.duration })
                
                // All-Time Stats
                statsCard(title: "All-Time Stats",
                         count: viewModel.allTimeCompletedExercises.count,
                         duration: viewModel.allTimeCompletedExercises.reduce(0) { $0 + $1.duration })
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    // MARK: - Weekly Stats Section
    private var weeklyStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Leaderboard")
                .font(.title2)
                .bold()
            
            // Weekly Completions
            leaderboardList(title: "Most Completions",
                          entries: viewModel.leaderboardStats?.weeklyLeaderboard ?? [])
            
            // Weekly Duration
            leaderboardList(title: "Longest Duration",
                          entries: viewModel.leaderboardStats?.weeklyLeaderboardByDuration ?? [])
        }
    }
    
    // MARK: - Popular Exercises Section
    private var popularExercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Exercises")
                .font(.title2)
                .bold()
            
            ForEach(viewModel.leaderboardStats?.popularExercises ?? [], id: \.id) { exercise in
                HStack {
                    Text(exercise.name)
                        .font(.headline)
                    Spacer()
                    Text("\(exercise.completions) completions")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 1)
            }
        }
    }
    
    // MARK: - All-Time Stats Section
    private var allTimeStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All-Time Leaderboard")
                .font(.title2)
                .bold()
            
            // All-Time Completions
            leaderboardList(title: "Most Completions",
                          entries: viewModel.leaderboardStats?.allTimeLeaderboard ?? [])
            
            // All-Time Duration
            leaderboardList(title: "Longest Duration",
                          entries: viewModel.leaderboardStats?.allTimeLeaderboardByDuration ?? [])
        }
    }
    
    // MARK: - Helper Views
    private func statsCard(title: String, count: Int, duration: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack(spacing: 20) {
                statItem(icon: "checkmark.circle.fill",
                        value: "\(count)",
                        label: "Exercises")
                
                statItem(icon: "clock.fill",
                        value: formatDuration(duration),
                        label: "Duration")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func statItem(icon: String, value: String, label: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func leaderboardList(title: String, entries: [LeaderboardEntry]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            let topEntries = entries.prefix(5)
            ForEach(Array(zip(topEntries.indices, topEntries)), id: \.1.id) { index, entry in
                HStack {
                    Text("#\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(width: 40)
                    
                    Text(entry.nickname.isEmpty ? "Anonymous" : entry.nickname)
                    
                    Spacer()
                    
                    if title.contains("Duration") {
                        Text(formatDuration(entry.totalDuration ?? 0))
                            .font(.headline)
                    } else {
                        Text("\(entry.totalCompletions)")
                            .font(.headline)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    StatisticsView()
}
