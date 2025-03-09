import Foundation
import FirebaseFirestore

struct UserCompletedExercise: Identifiable {
    let id: String
    let exerciseName: String
    let completedAt: Date
    let duration: Int
    let difficulty: String
    let categories: [String]
    
    init?(from document: QueryDocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        guard let name = data["name"] as? String,
              let completedAtTimestamp = data["completedAt"] as? Timestamp
        else { return nil }
        
        self.exerciseName = name
        self.completedAt = completedAtTimestamp.dateValue()
        self.duration = data["duration"] as? Int ?? 0
        self.difficulty = data["difficulty"] as? String ?? "unknown"
        self.categories = data["categories"] as? [String] ?? []
    }
}

struct LeaderboardEntry: Identifiable {
    let id: String // userId
    let nickname: String
    let rank: Int
    let totalCompletions: Int
    let totalDuration: Int?
    let totalDurationFormatted: String?
}

struct PopularExercise: Identifiable {
    let exerciseId: String
    let name: String
    let completions: Int
    let rank: Int
    
    var id: String { exerciseId } // Conformance to Identifiable
}

struct CategoryStats {
    let exerciseId: String
    let completionCount: Int
}

struct LeaderboardStats {
    let lastUpdated: Date
    let allTimeLeaderboard: [LeaderboardEntry]
    let allTimeLeaderboardByDuration: [LeaderboardEntry]
    let weeklyLeaderboard: [LeaderboardEntry]
    let weeklyLeaderboardByDuration: [LeaderboardEntry]
    let popularExercises: [PopularExercise]
    let categoryBreakdown: [CategoryStats]
    let totalCompletions: Int
    
    init?(from dict: [String: Any]) {
        // Last Updated
        guard let lastUpdatedTimestamp = dict["lastUpdated"] as? Timestamp else { return nil }
        self.lastUpdated = lastUpdatedTimestamp.dateValue()
        
        // Popular Exercises
        let popularExercisesData = dict["popularExercises"] as? [[String: Any]] ?? []
        self.popularExercises = popularExercisesData.compactMap { exercise in
            guard let exerciseId = exercise["exerciseId"] as? String,
                  let name = exercise["name"] as? String,
                  let completionCount = exercise["completionCount"] as? Int,
                  let rank = exercise["rank"] as? Int
            else { return nil }
            
            return PopularExercise(exerciseId: exerciseId,
                                  name: name,
                                  completions: completionCount,
                                  rank: rank)
        }
        
        // All Time Leaderboard
        let allTimeData = dict["allTimeLeaderboard"] as? [[String: Any]] ?? []
        self.allTimeLeaderboard = allTimeData.compactMap { entry in
            guard let userId = entry["userId"] as? String,
                  let nickname = entry["nickname"] as? String,
                  let rank = entry["rank"] as? Int,
                  let totalCompletions = entry["totalCompletions"] as? Int
            else { return nil }
            
            return LeaderboardEntry(id: userId,
                                   nickname: nickname,
                                   rank: rank,
                                   totalCompletions: totalCompletions,
                                   totalDuration: nil,
                                   totalDurationFormatted: nil)
        }
        
        // All Time Leaderboard By Duration
        let allTimeByDurationData = dict["allTimeLeaderboardByDuration"] as? [[String: Any]] ?? []
        self.allTimeLeaderboardByDuration = allTimeByDurationData.compactMap { entry in
            guard let userId = entry["userId"] as? String,
                  let nickname = entry["nickname"] as? String,
                  let rank = entry["rank"] as? Int,
                  let totalCompletions = entry["completionsCount"] as? Int,
                  let totalDuration = entry["totalDuration"] as? Int,
                  let totalDurationFormatted = entry["totalDurationFormatted"] as? String
            else { return nil }
            
            return LeaderboardEntry(id: userId,
                                   nickname: nickname,
                                   rank: rank,
                                   totalCompletions: totalCompletions,
                                   totalDuration: totalDuration,
                                   totalDurationFormatted: totalDurationFormatted)
        }
        
        // Weekly Leaderboards
        let weeklyData = dict["weeklyLeaderboard"] as? [[String: Any]] ?? []
        self.weeklyLeaderboard = weeklyData.compactMap { entry in
            guard let userId = entry["userId"] as? String,
                  let nickname = entry["nickname"] as? String,
                  let rank = entry["rank"] as? Int,
                  let totalCompletions = entry["totalCompletions"] as? Int
            else { return nil }
            
            return LeaderboardEntry(id: userId,
                                   nickname: nickname,
                                   rank: rank,
                                   totalCompletions: totalCompletions,
                                   totalDuration: nil,
                                   totalDurationFormatted: nil)
        }
        
        // Weekly Leaderboard By Duration
        let weeklyByDurationData = dict["weeklyLeaderboardByDuration"] as? [[String: Any]] ?? []
        self.weeklyLeaderboardByDuration = weeklyByDurationData.compactMap { entry in
            guard let userId = entry["userId"] as? String,
                  let nickname = entry["nickname"] as? String,
                  let rank = entry["rank"] as? Int,
                  let totalCompletions = entry["completionsCount"] as? Int,
                  let totalDuration = entry["totalDuration"] as? Int,
                  let totalDurationFormatted = entry["totalDurationFormatted"] as? String
            else { return nil }
            
            return LeaderboardEntry(id: userId,
                                   nickname: nickname,
                                   rank: rank,
                                   totalCompletions: totalCompletions,
                                   totalDuration: totalDuration,
                                   totalDurationFormatted: totalDurationFormatted)
        }
        
        // Category Breakdown
        let categoryData = dict["categoryBreakdown"] as? [[String: Any]] ?? []
        self.categoryBreakdown = categoryData.compactMap { category in
            guard let exerciseId = category["exerciseId"] as? String,
                  let completionCount = category["completionCount"] as? Int
            else { return nil }
            
            return CategoryStats(exerciseId: exerciseId,
                                completionCount: completionCount)
        }
        
        // Total Completions
        self.totalCompletions = dict["totalCompletions"] as? Int ?? 0
    }
}

@MainActor
final class StatisticsViewModel: ObservableObject {
    private let db = Firestore.firestore()
    @Published var leaderboardStats: LeaderboardStats?
    @Published var userNickname: String = "Loading..."
    @Published var allTimeCompletedExercises: [UserCompletedExercise] = []
    @Published var weeklyCompletedExercises: [UserCompletedExercise] = []
    
    private func formatNickname(_ nickname: String) -> String {
        let parts = nickname.split(separator: "_")
        if parts.count >= 2 {
            return "\(parts[0])_\(parts[1])"
        }
        return nickname
    }
    
    private func fetchUserNickname() async {
        do {
            if let userId = try? KeychainManager.shared.getUserId(),
               let userData = try await UserService.shared.getUserData(userId: userId) {
                self.userNickname = formatNickname(userData.nickname)
            }
        } catch {
            // Error handling for user nickname fetch
            self.userNickname = "Anonymous"
        }
    }
    
    init() {
        Task {
            await fetchUserNickname()
            await fetchLeaderboardStats()
            await fetchUserCompletedExercises()
        }
    }
    
    private func getLastWeekDate() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    }
    
    func fetchLeaderboardStats() async {
        do {
            let snapshot = try await db.collection("leaderboardStats").document("latest").getDocument()
            
            guard let data = snapshot.data() else {
                // No data found in leaderboardStats
                return
            }
            
            if let stats = LeaderboardStats(from: data) {
                self.leaderboardStats = stats
                
                // Successfully parsed leaderboard stats
            } else {
                // Failed to parse leaderboard stats
            }
        } catch {
            // Error handling for leaderboard stats fetch
        }
    }
    
    func fetchUserCompletedExercises() async {
        do {
            guard let userId = try? KeychainManager.shared.getUserId() else {
                // UserId not found
                return
            }
            // Fetching completions for user
            let userCompletionsRef = db.collection("completedExercises")
                .document(userId)
                .collection("completions")
            
            let snapshot = try await userCompletionsRef.getDocuments()
            
            // Parse all exercises
            let allExercises = snapshot.documents.compactMap { UserCompletedExercise(from: $0) }
            self.allTimeCompletedExercises = allExercises
            
            // Filter for weekly exercises
            let lastWeekDate = getLastWeekDate()
            self.weeklyCompletedExercises = allExercises.filter { $0.completedAt >= lastWeekDate }
            
            // Successfully fetched user completed exercises
            
        } catch {
            // Error handling for completed exercises fetch
        }
    }
}