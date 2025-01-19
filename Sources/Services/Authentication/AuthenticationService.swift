import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

// Temel authentication özellikleri
protocol AuthenticationServiceBase {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<AuthenticationState, Never> { get }
}

// Giriş işlemleri için protokol
protocol SignInServiceProtocol: AuthenticationServiceBase {
    func signIn(email: String, password: String) async throws
}

// Kayıt işlemleri için protokol
protocol RegistrationServiceProtocol: AuthenticationServiceBase {
    func register(email: String, password: String) async throws
}

// Çıkış işlemleri için protokol
protocol SignOutServiceProtocol: AuthenticationServiceBase {
    func signOut() async throws
}

// Tüm authentication işlemlerini birleştiren protokol
protocol AuthenticationServiceProtocol: SignInServiceProtocol, RegistrationServiceProtocol, SignOutServiceProtocol {}

// Tüm authentication işlemlerini içeren ana servis
final class AuthenticationService: AuthenticationServiceProtocol {
    private let auth: Auth
    private let db: Firestore
    private let deviceVerificationService: DeviceVerificationServiceProtocol
    private var stateListener: AuthStateDidChangeListenerHandle?
    
    private let authStateSubject = CurrentValueSubject<AuthenticationState, Never>(.unauthenticated)
    var authStatePublisher: AnyPublisher<AuthenticationState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    var currentUser: User? {
        auth.currentUser
    }
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    init(auth: Auth = Auth.auth(),
         db: Firestore = Firestore.firestore(),
         deviceVerificationService: DeviceVerificationServiceProtocol? = nil) {
        self.auth = auth
        self.db = db
        #if DEBUG
        self.deviceVerificationService = deviceVerificationService ?? MockDeviceVerificationService()
        #else
        self.deviceVerificationService = deviceVerificationService ?? DeviceVerificationService()
        #endif
        setupAuthStateListener()
    }
    
    deinit {
        // Listener'ı temizle
        if let listener = stateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        stateListener = auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.authStateSubject.send(.authenticated(user))
            } else {
                self?.authStateSubject.send(.unauthenticated)
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        authStateSubject.send(.authenticating)
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            
            if await shouldVerifyDevice(for: result.user) {
                let isDeviceValid = try await deviceVerificationService.verifyDevice()
                if !isDeviceValid {
                    try await signOut()
                    throw AuthError.deviceVerificationFailed
                }
            }
            
            try await updateLastSignInTime(for: result.user)
            authStateSubject.send(.authenticated(result.user))
        } catch let error as NSError {
            authStateSubject.send(.unauthenticated)
            
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                throw AuthError.accountNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                throw AuthError.invalidCredentials
            case AuthErrorCode.networkError.rawValue:
                throw NetworkError.noInternet
            default:
                throw convertFirebaseError(error)
            }
        }
    }
    
    func register(email: String, password: String) async throws {
        authStateSubject.send(.authenticating)
        
        do {
            // Önce cihaz doğrulaması yap
            let isDeviceValid = try await deviceVerificationService.verifyDevice()
            guard isDeviceValid else {
                authStateSubject.send(.unauthenticated)
                throw AuthError.deviceVerificationFailed
            }
            
            // Firebase Auth'da kullanıcı oluştur
            let result = try await auth.createUser(withEmail: email, password: password)
            
            do {
                // Firestore'a kullanıcı verilerini kaydet
                try await saveUserData(user: result.user, email: email)
                // Başarılı kayıttan sonra state'i güncelle
                authStateSubject.send(.authenticated(result.user))
            } catch {
                // Firestore'a kayıt başarısız olursa kullanıcıyı sil
                try? await result.user.delete()
                authStateSubject.send(.unauthenticated)
                throw convertFirebaseError(error as NSError)
            }
        } catch let error as NSError {
            authStateSubject.send(.unauthenticated)
            
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw AuthError.emailAlreadyInUse
            case AuthErrorCode.invalidEmail.rawValue:
                throw AuthError.invalidEmail
            case AuthErrorCode.weakPassword.rawValue:
                throw AuthError.weakPassword
            case AuthErrorCode.networkError.rawValue:
                throw NetworkError.noInternet
            case AuthErrorCode.tooManyRequests.rawValue:
                throw AuthError.tooManyAttempts
            default:
                throw convertFirebaseError(error)
            }
        }
    }
    
    func signOut() async throws {
        do {
            try auth.signOut()
            authStateSubject.send(.unauthenticated)
        } catch {
            throw AuthError.notAuthenticated
        }
    }
    
    private func shouldVerifyDevice(for user: User) async -> Bool {
        do {
            let snapshot = try await db.collection("users")
                .document(user.uid)
                .collection("verifiedDevices")
                .order(by: "lastUsedAt", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            guard let lastDevice = snapshot.documents.first,
                  let lastUsedAt = lastDevice.data()["lastUsedAt"] as? Timestamp else {
                return true
            }
            
            let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
            return lastUsedAt.dateValue() < thirtyDaysAgo
        } catch {
            return true
        }
    }
    
    private func updateLastSignInTime(for user: User) async throws {
        try await db.collection("users")
            .document(user.uid)
            .updateData([
                "lastSignInAt": FieldValue.serverTimestamp()
            ])
    }
    
    private func saveUserData(user: User, email: String) async throws {
        try await db.collection("users")
            .document(user.uid)
            .setData([
                "email": email,
                "createdAt": FieldValue.serverTimestamp(),
                "lastSignInAt": FieldValue.serverTimestamp()
            ])
    }
    
    private func convertFirebaseError(_ error: NSError) -> AppErrorProtocol {
        return AppError(
            title: "Hata",
            message: error.localizedDescription,
            code: error.code,
            errorType: .authentication,
            underlyingError: error
        )
    }
}