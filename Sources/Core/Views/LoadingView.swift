import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .scaleEffect(2)
                    .tint(.white)
            }
            .frame(width: 100, height: 100)
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

// MARK: - ViewModifier
struct LoadingViewModifier: ViewModifier {
    @ObservedObject var loadingService: LoadingService
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(!loadingService.isLoading)
            
            if loadingService.isLoading {
                LoadingView()
                    .transition(.opacity)
                    .animation(.easeInOut, value: loadingService.isLoading)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - View Extensions
extension View {
    func withLoading(_ loadingService: LoadingService) -> some View {
        ZStack {
            self
            
            if loadingService.isLoading {
                LoadingView()
            }
        }
    }
}

#Preview {
    LoadingView()
} 