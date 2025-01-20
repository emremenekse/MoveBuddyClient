import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var loadingService: LoadingService
    @EnvironmentObject var authenticationService: AuthenticationService
    @State private var showLogin = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("MoveBuddy'ye Hoş Geldiniz")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    NavigationLink(value: "registration") {
                        Text("Kayıt Ol")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Giriş Yap")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                HStack {
                    VStack { Divider() }
                    Text("veya").font(.subheadline).foregroundColor(.secondary)
                    VStack { Divider() }
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await viewModel.signInWithApple()
                        }
                    }) {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Apple ile devam et")
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.signInWithGoogle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Google ile devam et")
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationDestination(for: String.self) { route in
                switch route {
                case "registration":
                    RegistrationView()
                default:
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AppViewModel.shared)
        .environmentObject(LoadingService.shared)
        .environmentObject(AuthenticationService.shared)
} 