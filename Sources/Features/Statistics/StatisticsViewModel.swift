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
    let id: String // exerciseId
    let name: String
    let completionCount: Int
    let rank: Int
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
            
            return PopularExercise(id: exerciseId,
                                  name: name,
                                  completionCount: completionCount,
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
    
    @Published var allTimeCompletedExercises: [UserCompletedExercise] = []
    @Published var weeklyCompletedExercises: [UserCompletedExercise] = []
    
    init() {
        Task {
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
                print("❌ No data found in leaderboardStats/latest document")
                return
            }
            
            if let stats = LeaderboardStats(from: data) {
                self.leaderboardStats = stats
                
                print("\n📊 Leaderboard Stats:")
                print("-------------------")
                print("Last Updated: \(stats.lastUpdated)")
                print("Total Completions: \(stats.totalCompletions)")
                
                print("\n🏆 All-Time Leaderboard:")
                for entry in stats.allTimeLeaderboard {
                    print("\(entry.rank). \(entry.nickname): \(entry.totalCompletions) total completions")
                }
                
                print("\n⏱ All-Time Leaderboard By Duration:")
                for entry in stats.allTimeLeaderboardByDuration {
                    print("\(entry.rank). \(entry.nickname): \(entry.totalDurationFormatted ?? "0m") total time")
                }
                
                print("\n🏅 Weekly Leaderboard:")
                for entry in stats.weeklyLeaderboard {
                    print("\(entry.rank). \(entry.nickname): \(entry.totalCompletions) completions this week")
                }
                
                print("\n⌛️ Weekly Leaderboard By Duration:")
                for entry in stats.weeklyLeaderboardByDuration {
                    print("\(entry.rank). \(entry.nickname): \(entry.totalDurationFormatted ?? "0m") this week")
                }
                
                print("\n📈 Popular Exercises:")
                for exercise in stats.popularExercises {
                    print("\(exercise.rank). \(exercise.name): \(exercise.completionCount) completions")
                }
                
                print("\n📋 Category Breakdown:")
                for category in stats.categoryBreakdown {
                    print("Exercise ID: \(category.exerciseId), Completions: \(category.completionCount)")
                }
            } else {
                print("❌ Failed to parse leaderboard stats")
            }
        } catch {
            print("❌ Error fetching leaderboard stats: \(error.localizedDescription)")
        }
    }
    
    func fetchUserCompletedExercises() async {
        do {
            guard let userId = try? KeychainManager.shared.getUserId() else {
                print("❌ Error: UserId not found")
                return
            }
            print("👤 User ID: \(userId)")
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
            
            // Print All-Time Exercises
            print("\n🏆 All-Time Completed Exercises:")
            print("--------------------------------")
            for exercise in allTimeCompletedExercises {
                printExerciseDetails(exercise)
            }
            print("\nTotal all-time completed exercises: \(allTimeCompletedExercises.count)")
            
            // Print Weekly Exercises
            print("\n📈 Weekly Completed Exercises:")
            print("------------------------------")
            for exercise in weeklyCompletedExercises {
                printExerciseDetails(exercise)
            }
            print("\nTotal weekly completed exercises: \(weeklyCompletedExercises.count)")
            
        } catch {
            print("❌ Error fetching completed exercises: \(error.localizedDescription)")
        }
    }
    
    private func printExerciseDetails(_ exercise: UserCompletedExercise) {
        print("\n🏋️ Exercise: \(exercise.exerciseName)")
        print("   📅 Completed: \(exercise.completedAt)")
        print("   ⏱️ Duration: \(exercise.duration) seconds")
        print("   🎯 Difficulty: \(exercise.difficulty)")
        print("   🎟️ Categories: \(exercise.categories.joined(separator: ", "))")
    }
}