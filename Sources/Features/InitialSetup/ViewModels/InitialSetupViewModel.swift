import Foundation
import Combine

@MainActor
final class InitialSetupViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var selectedWorkspaceTypes: Set<WorkspaceType> = []
    @Published var selectedExerciseTypes: Set<ExerciseType> = []
    @Published var workSchedule: [WeekDay: WorkSchedule.WorkDay] = [:]
    @Published var errorMessage: String?
    @Published var isSetupComplete: Bool = false
    
    private let service: InitialSetupService
    
    init(service: InitialSetupService? = nil) {
        self.service = service ?? InitialSetupService.shared
    }
    
    var canProceed: Bool {
        !name.isEmpty && 
        !selectedWorkspaceTypes.isEmpty && 
        !selectedExerciseTypes.isEmpty &&
        !workSchedule.isEmpty
    }
    
    func toggleWorkspaceType(_ type: WorkspaceType) {
        if selectedWorkspaceTypes.contains(type) {
            selectedWorkspaceTypes.remove(type)
        } else {
            selectedWorkspaceTypes.insert(type)
        }
    }
    
    func toggleExerciseType(_ type: ExerciseType) {
        if selectedExerciseTypes.contains(type) {
            selectedExerciseTypes.remove(type)
        } else {
            selectedExerciseTypes.insert(type)
        }
    }
    
    func updateWorkSchedule(for day: WeekDay, startHour: Int, endHour: Int) {
        if startHour >= 0 && startHour < endHour && endHour <= 23 {
            workSchedule[day] = WorkSchedule.WorkDay(startHour: startHour, endHour: endHour)
        }
    }
    
    func removeWorkDay(_ day: WeekDay) {
        workSchedule.removeValue(forKey: day)
    }
    
    func saveUserInfo() {
        do {
            let userInfo = InitialUserInfo(
                name: name,
                workspaceType: selectedWorkspaceTypes,
                exercisePreferences: selectedExerciseTypes,
                workSchedule: WorkSchedule(workDays: workSchedule)
            )
            
            try service.saveUserInfo(userInfo)
            isSetupComplete = true
            errorMessage = nil
            
        } catch {
            errorMessage = "Bilgiler kaydedilirken bir hata oluştu"
        }
    }
    
    func loadSavedInfo() {
        do {
            if let savedInfo = try service.getUserInfo() {
                name = savedInfo.name
                selectedWorkspaceTypes = savedInfo.workspaceType
                selectedExerciseTypes = savedInfo.exercisePreferences
                workSchedule = savedInfo.workSchedule.workDays
            }
        } catch {
            errorMessage = "Kayıtlı bilgiler yüklenirken bir hata oluştu"
        }
    }
} 