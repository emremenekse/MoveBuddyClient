import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: String = LocalizationManager.shared.currentLanguage
    @State private var showLanguageChangeAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Personal Information
                Section("profile.personal.info".localized) {
                    TextField("profile.name".localized, text: $viewModel.name)
                    HStack {
                        Text("profile.nickname".localized)
                        Spacer()
                        Text(viewModel.displayNickname)
                            .foregroundColor(.gray)
                    }
                }
                
                // MARK: - Language Settings
                Section("profile.language.settings".localized) {
                    Picker(selection: $selectedLanguage, label: Text("profile.language".localized)) {
                        Text("English").tag("en")
                        Text("Türkçe").tag("tr")
                    }
                    .onChange(of: selectedLanguage) { _ in
                        LocalizationManager.shared.setLanguage(selectedLanguage)
                        showLanguageChangeAlert = true
                    }
                }
                
                // MARK: - Workspace
                Section("profile.workspace".localized) {
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
                
                // MARK: - Exercise Preferences
                Section("profile.exercise.preferences".localized) {
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
                
                // MARK: - Work Schedule
                Section("profile.work.schedule".localized) {
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
                                    newWorkDays[day] = WorkSchedule.WorkDay(startHour: 0, endHour: 24)
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
            .navigationTitle("profile.title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.save".localized) {
                        Task {
                            await viewModel.saveChanges()
                        }
                    }
                    .disabled(!viewModel.hasChanges)
                }
            }
            .alert("common.error".localized, isPresented: $viewModel.showError) {
                Button("common.ok".localized, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("profile.language.changed.title".localized, isPresented: $showLanguageChangeAlert) {
                Button("common.ok".localized, role: .cancel) {}
            } message: {
                Text("profile.language.changed.message".localized)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel.shared)
} 