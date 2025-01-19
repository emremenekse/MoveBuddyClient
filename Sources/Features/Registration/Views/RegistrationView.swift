import SwiftUI
import FirebaseAuth

struct RegistrationView: View {
    @ObservedObject var appViewModel: AppViewModel
    @StateObject private var viewModel: RegistrationViewModel
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        _viewModel = StateObject(wrappedValue: RegistrationViewModel(
            registrationService: appViewModel.authService,
            errorHandler: ErrorHandlingService.shared
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Hesap Oluştur")
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
                        
                        SecureField("En az 6 karakter", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
                    }
                    
                    // Şifre tekrar alanı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Şifre Tekrar")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        
                        SecureField("Şifrenizi tekrar girin", text: $viewModel.passwordConfirmation)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)
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
                        await viewModel.register()
                    }
                } label: {
                    Text("Kayıt Ol")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .disabled(viewModel.isLoading)
                
                Text("Kayıt olarak, Kullanım Koşulları ve Gizlilik Politikası'nı kabul etmiş olursunuz.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Kayıt Ol")
        
    }
}

#Preview {
    NavigationStack {
        RegistrationView(appViewModel: AppViewModel())
    }
} 