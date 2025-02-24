import Foundation
import FirebaseFirestore
import Combine



struct ExerciseCompletion {
    let completedAt: Date
    let difficulty: String
    let duration: Int
    let exerciseId: Int
    let name: String
    let categories: [String]

    init?(from dict: [String: Any]) {

        guard let timestamp = dict["completedAt"] as? Timestamp else {
            return nil
        }
        guard let difficulty = dict["difficulty"] as? String else {
            return nil
        }
        guard let duration = dict["duration"] as? Int else {
            return nil
        }

        // 🔥 Handle Int, Double, NSNumber, *and now String*
        let exerciseId: Int
        if let number = dict["exerciseId"] as? NSNumber {
            exerciseId = number.intValue
        } else if let intValue = dict["exerciseId"] as? Int {
            exerciseId = intValue
        } else if let doubleValue = dict["exerciseId"] as? Double {
            exerciseId = Int(doubleValue)
        }
        // ➜ NEW: Handle String that can be converted to Int
        else if let stringValue = dict["exerciseId"] as? String, 
                let convertedInt = Int(stringValue) {
            exerciseId = convertedInt
        } else {
            return nil
        }

        guard let name = dict["name"] as? String else {
            return nil
        }
        guard let categories = dict["categories"] as? [String] else {
            return nil
        }

        self.completedAt = timestamp.dateValue()
        self.difficulty = difficulty
        self.duration = duration
        self.exerciseId = exerciseId
        self.name = name
        self.categories = categories

    }
}







struct UserStats {
    let userId: String
    var completions: [ExerciseCompletion]

    init(userId: String, from dict: [String: Any]) {
        self.userId = userId

        // Debug: Check if `completions` exists
        guard let rawCompletions = dict["completions"] else {
            self.completions = []
            return
        }


        // Ensure completions is correctly cast as an array of dictionaries
        let completionsData = dict["completions"] as? [[String: Any]] ?? []
        
        // Debugging: Print each completion entry
        for (index, entry) in completionsData.enumerated() {
            print("🔍 Completion \(index + 1) for \(userId):", entry)
        }
        
        // Convert completions safely
        self.completions = completionsData.compactMap { ExerciseCompletion(from: $0) }

    }
}




struct ExerciseStatsDocument {
    let lastUpdated: Date
    let totalCompletions: Int
    let totalUsers: Int
    var userStats: [String: UserStats]

    init?(from dict: [String: Any]) {

        // Handle lastUpdated
        if let timestamp = dict["lastUpdated"] as? Timestamp {
            self.lastUpdated = timestamp.dateValue()
        } else if let dateString = dict["lastUpdated"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = formatter.date(from: dateString) {
                self.lastUpdated = date
            } else {
                return nil
            }
        } else {
            return nil
        }

        guard let totalCompletions = dict["totalCompletions"] as? Int,
              let totalUsers = dict["totalUsers"] as? Int else {
            return nil
        }

        self.totalCompletions = totalCompletions
        self.totalUsers = totalUsers

        // 🔍 Debug: Check if `userStats` exists
        guard let userStatsData = dict["userStats"] as? [String: Any] else {
            return nil
        }

        self.userStats = userStatsData.compactMapValues { userData in
            guard let userDataDict = userData as? [String: Any] else {
                return nil
            }
            return UserStats(userId: userDataDict["userId"] as? String ?? "unknown", from: userDataDict)
        }

    }
}






@MainActor
final class StatisticsViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var exerciseStats: ExerciseStatsDocument?
    @Published var isLoading = false
    @Published var error: Error?
    
    // Computed properties for easy access
    var totalUsersCount: Int { exerciseStats?.totalUsers ?? 0 }
    var totalCompletionsCount: Int { exerciseStats?.totalCompletions ?? 0 }
    var lastUpdated: String {
        guard let date = exerciseStats?.lastUpdated else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    init() {
        // Call loadInitialData when the ViewModel is initialized
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        // Similar to ngOnInit in Angular
        await fetchUserProfiles()
        await fetchExercises()
        await fetchStatistics()
    }
    
    func fetchUserProfiles() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("userProfiles").limit(to: 33).getDocuments()
            print("\n=== User Profiles (33) ===\n")
            for document in snapshot.documents {
                if let data = document.data() as? [String: Any] {
                    print("User ID: \(document.documentID)")
                    print("Data: \(data)\n")
                }
            }
        } catch {
            self.error = error
            print("Error fetching user profiles: \(error.localizedDescription)")
        }
    }
    
    func fetchExercises() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("exercises").limit(to: 33).getDocuments()
            print("\n=== Exercises (33) ===\n")
            for document in snapshot.documents {
                if let data = document.data() as? [String: Any] {
                    print("Exercise ID: \(document.documentID)")
                    print("Data: \(data)\n")
                }
            }
        } catch {
            self.error = error
            print("Error fetching exercises: \(error.localizedDescription)")
        }
    }

    func fetchStatistics() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let document = try await db.collection("stats").document("exerciseStats").getDocument()
        print("\n=== Raw Firestore Data ===\n")
        
        guard let data = document.data() else {
            print("❌ No statistics data found")
            return
        }

        // Print raw Firestore data to confirm structure
        print(data)

        // Try to parse the document and debug failures
        if let stats = ExerciseStatsDocument(from: data) {
            self.exerciseStats = stats
            print("✅ Successfully parsed ExerciseStatsDocument!")
            
            // 🎉 Print the parsed data
            print("\n=== Parsed ExerciseStats ===")
            print("📅 Last Updated: \(stats.lastUpdated)")
            print("👥 Total Users: \(stats.totalUsers)")
            print("🏋️ Total Completions: \(stats.totalCompletions)")

            // Print user statistics
            print("\n=== User Stats ===")
            for (userId, userStats) in stats.userStats {
                print("\n👤 User ID: \(userId)")
                print("🔄 Number of Completions: \(userStats.completions.count)")
                
                for completion in userStats.completions {
                    print("\n📝 Exercise Name: \(completion.name)")
                    print("   📅 Completed At: \(completion.completedAt)")
                    print("   ⏳ Duration: \(completion.duration) seconds")
                    print("   🎯 Difficulty: \(completion.difficulty)")
                    print("   🏷 Categories: \(completion.categories.joined(separator: ", "))")
                }
            }
        } else {
            print("❌ Failed to parse statistics data.")
        }
    } catch {
        self.error = error
        print("⚠️ Error fetching statistics: \(error.localizedDescription)")
    }
}



    
    // Helper method to get user specific stats
    func getUserStats(for userId: String) -> [ExerciseCompletion] {
        return exerciseStats?.userStats[userId]?.completions ?? []
    }
    
    // Get top users by completion count
    func getTopUsers(limit: Int = 10) -> [(userId: String, completionCount: Int)] {
        guard let userStats = exerciseStats?.userStats else { return [] }
        
        return userStats
            .map { (userId: $0.key, completionCount: $0.value.completions.count) }
            .sorted { $0.completionCount > $1.completionCount }
            .prefix(limit)
            .map { ($0.userId, $0.completionCount) }
    }
    
    // Get most popular exercises
    func getMostPopularExercises(limit: Int = 5) -> [(name: String, count: Int)] {
        guard let userStats = exerciseStats?.userStats else { return [] }
        
        var exerciseCounts: [String: Int] = [:]
        
        for (_, stats) in userStats {
            for completion in stats.completions {
                exerciseCounts[completion.name, default: 0] += 1
            }
        }
        
        return exerciseCounts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (name: $0.key, count: $0.value) }
    }
    
}
