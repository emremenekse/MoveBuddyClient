import Foundation
import CryptoKit
import UIKit

class NicknameGenerator {
    private let adjectives = [
        "ThreatLevelMidnight", "AssistantToTheRegional", "BearsBeetsBattlestar", "PretzelDayEnthusiast",
        "ScrantonStrangler", "RegionalManagerVibes", "WorldsBestBoss", "PrisonMikeApproved",
        "ThatOneIntern", "IdentityTheftIsNotAJoke", "StaplerInJello", "CPRTrainingFail",
        "FireDrillMaster", "SerenityByJan", "FlonkertonChampion", "MichaelScottPaperCo",
        "KevinsFamousChili", "DunderMifflinLegend", "FinerThingsClubMember", "ItIsYourBirthday",
        "ThatsWhatSheSaid", "Waaaasup"
    ]
    
    private let nouns = [
        "Michael", "Dwight", "Jim", "Pam", "Stanley", "Kevin", "Angela", "Ryan", 
        "Kelly", "Creed", "Toby", "Phyllis", "Meredith", "Oscar", "Jan"
    ]

    static let shared = NicknameGenerator()
    
    private init() {}
    
    func generateNickname() -> String {
        // IDFV (Identifier for Vendor) kullanımı
        guard let idfv = UIDevice.current.identifierForVendor?.uuidString else {
            return "Anonymous_User_\(Int.random(in: 1000...9999))"
        }
        
        // SHA256 hash oluştur
        let hash = SHA256.hash(data: Data(idfv.utf8))
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        let hashValue = Int(hashString.prefix(8), radix: 16) ?? Int.random(in: 0..<10000)
        
        let adjective = adjectives[hashValue % adjectives.count]
        let noun = nouns[(hashValue / adjectives.count) % nouns.count]
        
        return "\(adjective)_\(noun)_\(hashValue % 10000)"
    }
}
