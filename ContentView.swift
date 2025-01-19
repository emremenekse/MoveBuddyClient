//
//  ContentView.swift
//  MoveBuddy
//
//  Created by Umut Emre Menekşe on 14.01.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: NotificationSettingsView()) {
                    Label("Bildirim Ayarları", systemImage: "bell.fill")
                }
                
                // Diğer menü öğeleri
                Label("Egzersizler", systemImage: "figure.walk")
                Label("Profil", systemImage: "person.fill")
                Label("İstatistikler", systemImage: "chart.bar.fill")
                
                // Çıkış butonu
                Button(action: {
                    Task {
                        try? await appViewModel.authService.signOut()
                    }
                }) {
                    Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("MoveBuddy")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
