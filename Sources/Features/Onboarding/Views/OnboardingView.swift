import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var loadingService: LoadingService
    @EnvironmentObject var authenticationService: AuthenticationService
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.items.count, id: \.self) { index in
                        OnboardingPageView(item: viewModel.items[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        appViewModel.completeOnboarding()
                        viewModel.startApp()
                    }) {
                        Text("Başla")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.showSignIn) {
                AuthenticationView()
            }
            .navigationDestination(isPresented: $viewModel.showRegistration) {
                RegistrationView()
            }
        }
    }
}

struct OnboardingPageView: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: item.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.blue)
                .padding(.top, 60)
            
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
        .environmentObject(AppViewModel.shared)
        .environmentObject(LoadingService.shared)
        .environmentObject(AuthenticationService.shared)
} 