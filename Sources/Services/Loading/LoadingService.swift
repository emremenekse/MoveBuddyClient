import Foundation
import Combine

// Loading state yönetimi için ana servis
final class LoadingService: ObservableObject {
    // MARK: - Singleton
    static let shared = LoadingService()
    
    // MARK: - Properties
    @Published private(set) var isLoading: Bool = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func startLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
            let timestamp = self.dateFormatter.string(from: Date())
        }
    }

    func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
            let timestamp = self.dateFormatter.string(from: Date())
        }
    }
} 