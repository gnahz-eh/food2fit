//
//  MealCaptureView.swift
//  food2fit
//
//  Main view for capturing and analyzing meal photos
//

import SwiftUI
import PhotosUI
import SwiftData

struct MealCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let userProfile: UserProfile?
    
    @StateObject private var viewModel = MealAnalysisViewModel()
    @State private var showSourcePicker = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.showResults {
                    MealAnalysisResultsView(
                        viewModel: viewModel,
                        userProfile: userProfile,
                        onSave: saveMeal,
                        onNewMeal: resetForNewMeal
                    )
                } else if viewModel.isAnalyzing {
                    analysisProgressView
                } else if viewModel.hasImage {
                    imagePreviewView
                } else {
                    sourceSelectionView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCamera) {
                CameraView { image in
                    viewModel.setImage(image)
                }
            }
            .photosPicker(
                isPresented: $viewModel.showPhotoPicker,
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            )
            .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                Task {
                    await viewModel.loadImage()
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private var navigationTitle: String {
        if viewModel.showResults {
            return "Results"
        } else if viewModel.isAnalyzing {
            return "Analyzing..."
        } else if viewModel.hasImage {
            return "Review"
        } else {
            return "Add Meal"
        }
    }
    
    // MARK: - Source Selection View
    
    private var sourceSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient.appGradient.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient.appGradient)
            }
            
            VStack(spacing: 8) {
                Text("Capture Your Meal")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Take a photo or choose from your library")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Meal type selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Meal Type")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        MealTypeButton(
                            type: type,
                            isSelected: viewModel.mealType == type
                        ) {
                            viewModel.mealType = type
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            // Action buttons
            VStack(spacing: 12) {
                PrimaryButton("Take Photo", icon: "camera") {
                    viewModel.showCamera = true
                }
                
                SecondaryButton("Choose from Library", icon: "photo.on.rectangle") {
                    viewModel.showPhotoPicker = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Image Preview View
    
    private var imagePreviewView: some View {
        VStack(spacing: 24) {
            // Image preview
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 350)
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .padding()
            }
            
            // Meal type
            HStack {
                Image(systemName: viewModel.mealType.icon)
                    .foregroundColor(.accentColor)
                Text(viewModel.mealType.description)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.15))
            .cornerRadius(20)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                PrimaryButton("Analyze Meal", icon: "wand.and.stars") {
                    Task {
                        await viewModel.analyzeMeal(
                            userWeight: userProfile?.weightKg ?? 70,
                            fitnessGoal: userProfile?.fitnessGoal ?? .generalHealth
                        )
                    }
                }
                
                SecondaryButton("Retake Photo", icon: "arrow.counterclockwise") {
                    viewModel.reset()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Analysis Progress View
    
    private var analysisProgressView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Progress ring
            ZStack {
                ProgressRing(
                    progress: viewModel.analysisProgress,
                    lineWidth: 12,
                    color: .accentColor,
                    showLabel: false
                )
                .frame(width: 120, height: 120)
                
                Image(systemName: viewModel.analysisStage.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
            }
            
            VStack(spacing: 8) {
                Text(viewModel.analysisStage.rawValue)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Please wait while we analyze your meal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress steps
            VStack(alignment: .leading, spacing: 12) {
                ProgressStepRow(
                    title: "Recognizing food items",
                    isComplete: viewModel.analysisProgress >= 0.4,
                    isActive: viewModel.analysisStage == .recognizing
                )
                ProgressStepRow(
                    title: "Fetching nutrition data",
                    isComplete: viewModel.analysisProgress >= 0.6,
                    isActive: viewModel.analysisStage == .fetchingNutrition
                )
                ProgressStepRow(
                    title: "Calculating exercise",
                    isComplete: viewModel.analysisProgress >= 0.8,
                    isActive: viewModel.analysisStage == .calculatingExercise
                )
                ProgressStepRow(
                    title: "Generating advice",
                    isComplete: viewModel.analysisProgress >= 1.0,
                    isActive: viewModel.analysisStage == .generatingAdvice
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    private func saveMeal() {
        if let _ = viewModel.saveMeal(context: modelContext) {
            dismiss()
        }
    }
    
    private func resetForNewMeal() {
        viewModel.reset()
    }
}

// MARK: - Meal Type Button

struct MealTypeButton: View {
    let type: MealType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.title3)
                Text(type.description)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor : Color.appSecondaryBackground)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
    }
}

// MARK: - Progress Step Row

struct ProgressStepRow: View {
    let title: String
    let isComplete: Bool
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(isComplete || isActive ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                } else if isActive {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(isComplete || isActive ? .primary : .secondary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    MealCaptureView(userProfile: nil)
}
