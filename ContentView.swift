//
//  ContentView.swift
//  MoveBuddy
//
//  Created by Umut Emre Menekşe on 14.01.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var loadingService: LoadingService
    @EnvironmentObject var authenticationService: AuthenticationService
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: NotificationSettingsView()) {
                    Label("settings.notifications".localized, systemImage: "bell.fill")
                }
                
                // Diğer menü öğeleri
                Label("tab.exercises".localized, systemImage: "figure.walk")
                Label("tab.profile".localized, systemImage: "person.fill")
                Label("tab.statistics".localized, systemImage: "chart.bar.fill")
                
                // Çıkış butonu
                Button(action: {
                    Task {
                        try? await authenticationService.signOut()
                    }
                }) {
                    Label("auth.sign.out".localized, systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("app.title".localized)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel.shared)
        .environmentObject(LoadingService.shared)
        .environmentObject(AuthenticationService.shared)
}
