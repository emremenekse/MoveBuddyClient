import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Kişisel Bilgiler
                Section("Kişisel Bilgiler") {
                    TextField("Ad", text: $viewModel.name)
                }
                
                // MARK: - Çalışma Alanı
                Section("Çalışma Alanı") {
                    ForEach(WorkspaceType.allCases, id: \.self) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { viewModel.workspaceTypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.workspaceTypes.insert(type)
                                } else {
                                    viewModel.workspaceTypes.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                // MARK: - Egzersiz Tercihleri
                Section("Egzersiz Tercihleri") {
                    ForEach(ExerciseType.allCases, id: \.self) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { viewModel.exercisePreferences.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    viewModel.exercisePreferences.insert(type)
                                } else {
                                    viewModel.exercisePreferences.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                // MARK: - Çalışma Programı
                Section("Çalışma Programı") {
                    ForEach(WeekDay.allCases, id: \.self) { day in
                        if let workDay = viewModel.workSchedule.workDays[day] {
                            HStack {
                                Text(day.rawValue)
                                Spacer()
                                Text("\(workDay.startHour):00 - \(workDay.endHour):00")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // MARK: - Hesap İşlemleri
                Section {
                    Button(role: .destructive) {
                        viewModel.signOut()
                    } label: {
                        HStack {
                            Text("Çıkış Yap")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
            .navigationTitle("Profil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        Task {
                            await viewModel.saveChanges()
                        }
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
            .alert("Hata", isPresented: $viewModel.showError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel.shared)
} 