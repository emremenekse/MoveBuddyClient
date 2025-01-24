import SwiftUI

struct InitialSetupView: View {
    @StateObject private var viewModel = InitialSetupViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Hoş Geldiniz!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Sizin için en iyi deneyimi sunabilmemiz için lütfen aşağıdaki bilgileri doldurun.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Form alanları
                VStack(spacing: 24) {
                    // İsim alanı
                    FormField(title: "İsim/Takma İsim", placeholder: "İsminizi girin") {
                        TextField("İsminizi girin", text: $viewModel.name)
                            .textFieldStyle(.plain)
                            .textContentType(.nickname)
                    }
                    
                    // Çalışma Ortamı
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Çalışma Ortamı")
                            .font(.headline)
                        
                        ForEach(WorkspaceType.allCases, id: \.self) { type in
                            SelectableButton(
                                title: type.rawValue,
                                isSelected: viewModel.selectedWorkspaceTypes.contains(type)
                            ) {
                                viewModel.toggleWorkspaceType(type)
                            }
                        }
                    }
                    
                    // Hareket Tercihi
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hareket Tercihi")
                            .font(.headline)
                        
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            SelectableButton(
                                title: type.rawValue,
                                isSelected: viewModel.selectedExerciseTypes.contains(type)
                            ) {
                                viewModel.toggleExerciseType(type)
                            }
                        }
                    }
                    
                    // Çalışma Saatleri
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Çalışma Saatleri")
                            .font(.headline)
                        
                        ForEach(WeekDay.allCases, id: \.self) { day in
                            if let workDay = viewModel.workSchedule[day] {
                                HStack {
                                    Text(day.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(workDay.startHour):00 - \(workDay.endHour):00")
                                        .foregroundColor(.secondary)
                                    Button {
                                        viewModel.removeWorkDay(day)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red.opacity(0.7))
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            } else {
                                SelectableButton(
                                    title: day.rawValue,
                                    subtitle: "Ekle",
                                    isSelected: false
                                ) {
                                    viewModel.updateWorkSchedule(for: day, startHour: 0, endHour: 24)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Başla butonu
                Button {
                    viewModel.saveUserInfo()
                } label: {
                    if viewModel.canProceed {
                        Text("Başla")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    } else {
                        Text("Başla")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(12)
                    }
                }
                .disabled(!viewModel.canProceed)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding(.vertical, 24)
        }
        .onChange(of: viewModel.isSetupComplete) { _, isComplete in
            if isComplete {
                appViewModel.completeInitialSetup()
            }
        }
    }
}

// MARK: - Supporting Views
struct FormField<Content: View>: View {
    let title: String
    let placeholder: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            content()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

struct SelectableButton: View {
    let title: String
    var subtitle: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .blue)
                }
            }
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(10)
            .animation(.easeInOut, value: isSelected)
        }
    }
}

#Preview {
    InitialSetupView()
        .environmentObject(AppViewModel.shared)
} 