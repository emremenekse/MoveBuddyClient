import SwiftUI

struct ExercisesView: View {
    @StateObject private var viewModel = ExercisesViewModel()
    @State private var searchText = ""
    @State private var selectedExercise: Exercise?
    @State private var showingReminderSheet = false
    @State private var showingDetailSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Filtreler
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Kategori filtreleri
                        ForEach(ExerciseCategory.allCases) { category in
                            FilterChip(
                                title: category.title,
                                icon: category.icon,
                                isSelected: viewModel.selectedCategory == category,
                                action: {
                                    viewModel.selectCategory(
                                        viewModel.selectedCategory == category ? nil : category
                                    )
                                }
                            )
                        }
                        
                        Divider()
                            .frame(height: 24)
                        
                        // Ortam filtreleri
                        ForEach(ExerciseEnvironment.allCases) { environment in
                            FilterChip(
                                title: environment.title,
                                icon: environment.icon,
                                isSelected: viewModel.selectedEnvironment == environment,
                                action: {
                                    viewModel.selectEnvironment(
                                        viewModel.selectedEnvironment == environment ? nil : environment
                                    )
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // MARK: - Egzersiz Listesi
                if viewModel.filteredExercises.isEmpty {
                    ContentUnavailableView(
                        "Egzersiz Bulunamadı",
                        systemImage: "figure.walk",
                        description: Text("Seçili filtrelerle eşleşen egzersiz bulunamadı.")
                    )
                } else {
                    List(viewModel.filteredExercises) { exercise in
                        ExerciseRow(
                            exercise: exercise,
                            isSelected: viewModel.isExerciseSelected(exercise.id),
                            onAddTap: {
                                selectedExercise = exercise
                                showingReminderSheet = true
                            },
                            onRemoveTap: {
                                viewModel.removeExercise(exercise.id)
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExercise = exercise
                            showingDetailSheet = true
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Egzersizler")
            .searchable(
                text: Binding(
                    get: { searchText },
                    set: { newValue in
                        searchText = newValue
                        viewModel.updateSearchText(newValue)
                    }
                ),
                prompt: "Egzersiz Ara"
            )
            .sheet(isPresented: $showingReminderSheet) {
                if let exercise = selectedExercise {
                    NavigationView {
                        ReminderIntervalSheet(exercise: exercise, viewModel: viewModel)
                    }
                }
            }
            .sheet(isPresented: $showingDetailSheet) {
                if let exercise = selectedExercise {
                    NavigationView {
                        ExerciseDetailSheet(exercise: exercise)
                    }
                }
            }
            .onChange(of: showingReminderSheet) { newValue in
                if !newValue {
                    selectedExercise = nil
                }
            }
            .onChange(of: showingDetailSheet) { newValue in
                if !newValue {
                    selectedExercise = nil
                }
            }
        }
    }
}

// MARK: - Supporting Views
private struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(isSelected ? .blue : .primary)
            .clipShape(Capsule())
        }
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onAddTap: () -> Void
    let onRemoveTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Egzersiz görseli ve bilgileri
            HStack(spacing: 16) {
                // Egzersiz görseli
                if let imageURL = exercise.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color(.systemGray5)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "figure.walk")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(width: 60, height: 60)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Egzersiz bilgileri
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    Text(exercise.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Ekleme/Kaldırma butonu
            Group {
                if isSelected {
                    Button(action: onRemoveTap) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: onAddTap) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { } // Buton tıklamalarının row'a yayılmasını engelle
        }
        .padding(.vertical, 8)
    }
}

private struct ExerciseDetailSheet: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Görsel veya Video
                    Group {
                        if let videoURL = exercise.videoURL {
                            // TODO: Video Player eklenecek
                            Link(destination: videoURL) {
                                VideoPlaceholder()
                            }
                        } else if let imageURL = exercise.imageURL {
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color(.systemGray5)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Color(.systemGray6)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    Image(systemName: "figure.walk")
                                        .font(.largeTitle)
                                        .foregroundColor(.secondary)
                                }
                        }
                    }
                    
                    // Egzersiz Bilgileri
                    VStack(alignment: .leading, spacing: 16) {
                        // Başlık ve Süre
                        HStack {
                            Text(exercise.name)
                                .font(.title2)
                                .bold()
                            Spacer()
                            if let duration = exercise.formattedDuration {
                                Label(duration, systemImage: "clock")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Açıklama
                        Text(exercise.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Adımlar
                        if let steps = exercise.steps {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Adımlar")
                                    .font(.headline)
                                
                                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("\(index + 1)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .frame(width: 24)
                                        
                                        Text(step)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        
                        // Özellikler
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Özellikler")
                                .font(.headline)
                            
                            // Kategoriler
                            FlowLayout(spacing: 8) {
                                ForEach(exercise.categories, id: \.self) { category in
                                    TagView(
                                        icon: category.icon,
                                        text: category.title,
                                        color: .blue
                                    )
                                }
                            }
                            
                            // Ortamlar
                            FlowLayout(spacing: 8) {
                                ForEach(exercise.environments, id: \.self) { environment in
                                    TagView(
                                        icon: environment.icon,
                                        text: environment.title,
                                        color: .green
                                    )
                                }
                            }
                            
                            // Zorluk
                            if let difficulty = exercise.difficulty {
                                TagView(
                                    icon: "star.fill",
                                    text: difficulty.title,
                                    color: .orange
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views
private struct VideoPlaceholder: View {
    var body: some View {
        Color(.systemGray6)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
    }
}

private struct TagView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(proposal)
            
            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += currentRowHeight + spacing
                currentRowHeight = 0
            }
            
            currentX += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
        
        height = currentY + currentRowHeight
        
        return CGSize(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var currentRowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(proposal)
            
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += currentRowHeight + spacing
                currentRowHeight = 0
            }
            
            view.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(size)
            )
            
            currentX += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}

#Preview {
    ExercisesView()
} 