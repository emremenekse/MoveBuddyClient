import Foundation
import FirebaseFirestore

final class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    private let collectionName = "userProfiles"  // users yerine userProfiles kullanalım
    
    
    // Firestore'da kullanıcı dokümanını oluştur/güncelle
    func saveUserData(userId: String, nickname: String) async throws {
        
        let data: [String: Any] = [
            "userId": userId,
            "nickname": nickname,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection(collectionName).document(userId).setData(data, merge: true)
        } catch let error as NSError {
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
        
        let document = try await db.collection(collectionName).document(userId).getDocument()
        
        guard let data = document.data(),
              let userId = data["userId"] as? String,
              let nickname = data["nickname"] as? String else {
            return nil
        }
        
        return (userId, nickname)
    }
}
