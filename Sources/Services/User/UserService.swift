import Foundation
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let collectionName = "userProfiles"  // users yerine userProfiles kullanalım
    
    private init() {
        #if DEBUG
        print("[UserService] Initialized with collection: \(collectionName)")
        #endif
    }
    
    // Firestore'da kullanıcı dokümanını oluştur/güncelle
    func saveUserData(userId: String, nickname: String) async throws {
        #if DEBUG
        print("[UserService] Attempting to save data for userId: \(userId), nickname: \(nickname)")
        #endif
        
        let data: [String: Any] = [
            "userId": userId,
            "nickname": nickname,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection(collectionName).document(userId).setData(data, merge: true)
            #if DEBUG
            print("[UserService] Successfully saved data for userId: \(userId)")
            #endif
        } catch let error as NSError {
            #if DEBUG
            print("[UserService] Error saving data: \(error.localizedDescription)")
            print("[UserService] Error domain: \(error.domain), code: \(error.code)")
            if let errorDetails = error.userInfo[NSLocalizedDescriptionKey] {
                print("[UserService] Error details: \(errorDetails)")
            }
            #endif
            throw error
        }
    }
    
    // Nickname'in başka bir kullanıcı tarafından kullanılıp kullanılmadığını kontrol et
    func isNicknameAvailable(_ nickname: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("nickname", isEqualTo: nickname)
            .getDocuments()
        
        return snapshot.documents.isEmpty
    }
    
    // UserId ile kullanıcı bilgilerini getir
    func getUserData(userId: String) async throws -> (userId: String, nickname: String)? {
        #if DEBUG
        print("[UserService] Attempting to get data for userId: \(userId)")
        #endif
        
        let document = try await db.collection(collectionName).document(userId).getDocument()
        
        guard let data = document.data(),
              let userId = data["userId"] as? String,
              let nickname = data["nickname"] as? String else {
            return nil
        }
        
        return (userId, nickname)
    }
}
