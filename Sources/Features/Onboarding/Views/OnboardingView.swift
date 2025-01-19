import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    
    init(appViewModel: AppViewModel) {
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(appViewModel: appViewModel))
    }
    
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
                    
                    Button(action: {
                        viewModel.goToSignIn()
                    }) {
                        Text("Zaten hesabım var")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.showSignIn) {
                AuthenticationView(appViewModel: viewModel.appViewModel)
            }
            .navigationDestination(isPresented: $viewModel.showRegistration) {
                RegistrationView(appViewModel: viewModel.appViewModel)
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
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(appViewModel: AppViewModel())
    }
} 