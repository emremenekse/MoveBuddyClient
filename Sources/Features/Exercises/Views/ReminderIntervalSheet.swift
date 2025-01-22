import SwiftUI

struct ReminderIntervalSheet: View {
    let exercise: Exercise
    let viewModel: ExercisesViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(ReminderInterval.allCases) { interval in
                Button {
                    viewModel.addExercise(exercise.id, reminderInterval: interval)
                    dismiss()
                } label: {
                    HStack {
                        Text(interval.title)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Hatırlatma Aralığı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                }
            }
        }
    }
} 