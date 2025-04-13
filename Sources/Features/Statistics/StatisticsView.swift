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
            .navigationTitle("statistics.title".localized)
        }
    }
    
    // MARK: - User Statistics Section
    private var userStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("statistics.your.statistics".localized)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // User Nickname
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("statistics.welcome.back".localized)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(viewModel.userNickname)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                .padding(.vertical, 8)
                
                // Weekly Stats
                statsCard(title: "statistics.weekly.stats".localized,
                         count: viewModel.weeklyCompletedExercises.count,
                         duration: viewModel.weeklyCompletedExercises.reduce(0) { $0 + $1.duration })
                
                // All-Time Stats
                statsCard(title: "statistics.all.time.stats".localized,
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
            HStack {
                Text("statistics.weekly.leaderboard".localized)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.title2)
            }
            
            // Weekly Completions
            leaderboardList(title: "statistics.most.completions".localized,
                          entries: viewModel.leaderboardStats?.weeklyLeaderboard ?? [])
            
            // Weekly Duration
            leaderboardList(title: "statistics.longest.duration".localized,
                          entries: viewModel.leaderboardStats?.weeklyLeaderboardByDuration ?? [])
        }
    }
    
    // MARK: - Popular Exercises Section
    private var popularExercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("statistics.popular.exercises".localized)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.title2)
            }
            
            let maxCompletions = (viewModel.leaderboardStats?.popularExercises ?? []).map { $0.completions }.max() ?? 1
            
            ForEach(viewModel.leaderboardStats?.popularExercises.prefix(5) ?? [], id: \.id) { exercise in
                VStack(spacing: 8) {
                    HStack {
                        Text(exercise.name.localized)
                            .font(.system(size: 16, weight: .medium))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(exercise.completions)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.7), .blue.opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: CGFloat(exercise.completions) / CGFloat(maxCompletions) * geometry.size.width)
                            
                            Spacer(minLength: 0)
                        }
                    }
                    .frame(height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.vertical, 4)
            }
            
            // Legend
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: 8, height: 8)
                Text("statistics.number.of.completions".localized)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - All-Time Stats Section
    private var allTimeStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("statistics.all.time.leaderboard".localized)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.orange)
                    .font(.title2)
            }
            
            // All-Time Completions
            leaderboardList(title: "statistics.most.completions".localized,
                          entries: viewModel.leaderboardStats?.allTimeLeaderboard ?? [])
            
            // All-Time Duration
            leaderboardList(title: "statistics.longest.duration".localized,
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
                        label: "statistics.exercises".localized)
                
                statItem(icon: "clock.fill",
                        value: formatDuration(duration),
                        label: "statistics.duration".localized)
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
    
    private func getRankColor(_ index: Int) -> Color {
        switch index {
        case 0: return Color.orange   // Gold
        case 1: return Color.gray    // Silver
        case 2: return Color.brown   // Bronze
        default: return Color.blue.opacity(0.8)
        }
    }
    
    private func leaderboardList(title: String, entries: [LeaderboardEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("statistics.top.5".localized)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            let topEntries = entries.prefix(5)
            ForEach(Array(zip(topEntries.indices, topEntries)), id: \.1.id) { index, entry in
                HStack(spacing: 12) {
                    // Rank Circle
                    ZStack {
                        Circle()
                            .fill(getRankColor(index))
                            .frame(width: 36, height: 36)
                        
                        if index < 3 {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .offset(y: -12)
                        }
                        
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // User Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.nickname.isEmpty ? "statistics.anonymous".localized : entry.nickname)
                            .font(.system(size: 16, weight: .medium))
                        
                        // Stat Info
                        HStack {
                            Image(systemName: title == "statistics.longest.duration".localized ? "clock.fill" : "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Text(title == "statistics.longest.duration".localized ? formatDuration(entry.totalDuration ?? 0) : "\(entry.totalCompletions) " + "statistics.completions".localized)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
