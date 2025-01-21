import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var loadingService: LoadingService
    @EnvironmentObject var authenticationService: AuthenticationService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Giriş Yap")
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Email alanı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-posta")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        TextField("ornek@email.com", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    
                    // Şifre alanı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Şifre")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        SecureField("Şifrenizi girin", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    Task {
                        await viewModel.signIn()
                    }
                } label: {
                    Text("Giriş Yap")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .disabled(loadingService.isLoading)
                
                Button {
                    Task {
                        await viewModel.resetPassword()
                    }
                } label: {
                    Text("Şifremi Unuttum")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .disabled(loadingService.isLoading)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Giriş Yap")
        .onChange(of: viewModel.isLoginSuccessful) { success in
            if success {
                appViewModel.completeInitialSetup()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AppViewModel.shared)
            .environmentObject(LoadingService.shared)
            .environmentObject(AuthenticationService.shared)
    }
} 