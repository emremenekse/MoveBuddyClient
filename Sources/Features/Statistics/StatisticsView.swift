import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        Text("Statistics")
            .onAppear {
                Task {
                    await viewModel.fetchLeaderboardStats()
                }
            }
    }
}

#Preview {
    StatisticsView()
}
