import Foundation
import SwiftUI

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}

// MARK: - Localization Manager
class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {}
    
    // Get the current app language
    var currentLanguage: String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    // Check if the app is running in RTL mode
    var isRTL: Bool {
        return Locale.characterDirection(forLanguage: currentLanguage) == .rightToLeft
    }
    
    // Get available languages
    var availableLanguages: [String] {
        let paths = Bundle.main.paths(forResourcesOfType: "lproj", inDirectory: nil)
        return paths.compactMap { path -> String? in
            let langCode = URL(fileURLWithPath: path).lastPathComponent.replacingOccurrences(of: ".lproj", with: "")
            return langCode
        }
    }
    
    // Change the app language (requires app restart to take full effect)
    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Text Extension for SwiftUI
extension Text {
    static func localized(_ key: String) -> Text {
        return Text(key.localized)
    }
    
    static func localized(_ key: String, with arguments: CVarArg...) -> Text {
        return Text(key.localized(with: arguments))
    }
}
