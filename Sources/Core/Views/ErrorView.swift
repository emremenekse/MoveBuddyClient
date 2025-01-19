import SwiftUI

struct ErrorView: View {
    let error: AppErrorProtocol
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    let showIcon: Bool
    
    init(
        error: AppErrorProtocol,
        primaryButtonTitle: String = "Tamam",
        secondaryButtonTitle: String? = nil,
        showIcon: Bool = true,
        primaryAction: @escaping () -> Void = {},
        secondaryAction: (() -> Void)? = nil
    ) {
        self.error = error
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.showIcon = showIcon
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showIcon {
                Image(systemName: errorIcon)
                    .font(.system(size: 50))
                    .foregroundColor(errorColor)
            }
            
            Text(error.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(error.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                if let secondaryButtonTitle = secondaryButtonTitle {
                    Button(action: {
                        secondaryAction?()
                    }) {
                        Text(secondaryButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: primaryAction) {
                    Text(primaryButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
    }
    
    private var errorIcon: String {
        switch error.errorType {
        case .network:
            return "wifi.slash"
        case .authentication:
            return "person.fill.xmark"
        case .validation:
            return "exclamationmark.triangle.fill"
        case .server:
            return "server.rack"
        case .client:
            return "iphone.slash"
        case .unknown:
            return "exclamationmark.circle.fill"
        }
    }
    
    private var errorColor: Color {
        switch error.errorType {
        case .network:
            return .orange
        case .authentication:
            return .red
        case .validation:
            return .yellow
        case .server:
            return .red
        case .client:
            return .orange
        case .unknown:
            return .red
        }
    }
} 