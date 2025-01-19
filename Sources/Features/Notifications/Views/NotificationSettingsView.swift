import SwiftUI
import Foundation

struct NotificationSettingsView: View {
    @StateObject private var viewModel = NotificationViewModel()
    
    var body: some View {
        Form {
            Section("Bildirim Tercihleri") {
                Toggle("Egzersiz Hatırlatmaları", isOn: $viewModel.isNotificationsEnabled)
                    .onChange(of: viewModel.isNotificationsEnabled) { oldValue, newValue in
    if newValue {
        viewModel.requestNotificationPermission()
    }
}

                
                if viewModel.isNotificationsEnabled {
                    Button(action: {
                        viewModel.sendTestNotification()
                    }) {
                        Text("Test Bildirimi Gönder")
                    }
                    
                    Toggle("İstatistik Güncellemeleri", isOn: .constant(true))
                    Toggle("Profil Bildirimleri", isOn: .constant(true))
                }
            }
            
            Section("Aktif Bildirimler") {
                ForEach(viewModel.notifications) { notification in
                    VStack(alignment: .leading) {
                        Text(notification.title)
                            .font(.headline)
                        Text(notification.body)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Bildirim Ayarları")
    }
}