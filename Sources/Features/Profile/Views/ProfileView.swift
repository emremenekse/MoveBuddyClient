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
                        HStack {
                            Text(day.rawValue)
                            Spacer()
                            if let workDay = viewModel.workSchedule.workDays[day] {
                                HStack(spacing: 8) {
                                    Text("\(workDay.startHour):00 - \(workDay.endHour):00")
                                        .foregroundColor(.secondary)
                                    Button(role: .destructive) {
                                        var newWorkDays = viewModel.workSchedule.workDays
                                        newWorkDays.removeValue(forKey: day)
                                        viewModel.workSchedule.workDays = newWorkDays
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            } else {
                                Button {
                                    var newWorkDays = viewModel.workSchedule.workDays
                                    newWorkDays[day] = WorkSchedule.WorkDay(startHour: 9, endHour: 24)
                                    viewModel.workSchedule.workDays = newWorkDays
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
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