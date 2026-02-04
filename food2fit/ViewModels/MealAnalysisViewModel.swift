//
//  MealAnalysisViewModel.swift
//  food2fit
//
//  ViewModel for meal photo analysis
//

import Foundation
import SwiftUI
import SwiftData
import PhotosUI

/// View model for meal analysis flow
@MainActor
final class MealAnalysisViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedImage: UIImage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var mealType: MealType = .lunch
    
    @Published var isAnalyzing: Bool = false
    @Published var analysisProgress: Double = 0.0
    @Published var analysisStage: AnalysisStage = .idle
    
    @Published var recognizedFoods: [FoodRecognitionResult] = []
    @Published var nutritionInfo: [NutritionInfo] = []
    @Published var exerciseSuggestions: [ExerciseSuggestion] = []
    @Published var fitnessAdvice: FitnessAdvice?
    
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    @Published var showCamera: Bool = false
    @Published var showPhotoPicker: Bool = false
    @Published var showResults: Bool = false
    
    // MARK: - Private Properties
    
    private let foodRecognitionService = FoodRecognitionService.shared
    private let nutritionService = NutritionAPIService.shared
    private let exerciseService = ExerciseConversionService.shared
    private let adviceService = LLMAdviceService.shared
    
    // MARK: - Computed Properties
    
    var totalCalories: Int {
        nutritionInfo.reduce(0) { $0 + $1.calories }
    }
    
    var hasImage: Bool {
        selectedImage != nil
    }
    
    // MARK: - Methods
    
    /// Load image from PhotosPickerItem
    func loadImage() async {
        guard let item = selectedPhotoItem else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
            showError = true
        }
    }
    
    /// Set image from camera capture
    func setImage(_ image: UIImage) {
        selectedImage = image
    }
    
    /// Analyze the selected meal image
    func analyzeMeal(userWeight: Double, fitnessGoal: FitnessGoal) async {
        guard selectedImage != nil else {
            errorMessage = "Please select an image first"
            showError = true
            return
        }
        
        isAnalyzing = true
        analysisProgress = 0.0
        
        do {
            // Stage 1: Food Recognition
            analysisStage = .recognizing
            analysisProgress = 0.2
            
            let recognitionResults = try await foodRecognitionService.recognizeMultipleFoods(in: selectedImage!)
            recognizedFoods = recognitionResults
            
            analysisProgress = 0.4
            
            // Stage 2: Nutrition Lookup
            analysisStage = .fetchingNutrition
            var nutritionResults: [NutritionInfo] = []
            
            for result in recognitionResults {
                let nutrition = try await nutritionService.fetchNutrition(for: result.foodName)
                nutritionResults.append(nutrition)
            }
            
            nutritionInfo = nutritionResults
            analysisProgress = 0.6
            
            // Stage 3: Exercise Conversion
            analysisStage = .calculatingExercise
            let suggestions = exerciseService.calculateExerciseSuggestions(
                for: totalCalories,
                userWeight: userWeight
            )
            exerciseSuggestions = suggestions
            
            analysisProgress = 0.8
            
            // Stage 4: Generate Advice
            analysisStage = .generatingAdvice
            let foodNames = recognizedFoods.map { $0.foodName }
            let advice = try await adviceService.generateAdvice(
                foodItems: foodNames,
                totalCalories: totalCalories,
                userWeight: userWeight,
                fitnessGoal: fitnessGoal
            )
            fitnessAdvice = advice
            
            analysisProgress = 1.0
            analysisStage = .complete
            
            // Small delay to show completion
            try await Task.sleep(nanoseconds: 500_000_000)
            
            showResults = true
            
        } catch {
            errorMessage = "Analysis failed: \(error.localizedDescription)"
            showError = true
            analysisStage = .error
        }
        
        isAnalyzing = false
    }
    
    /// Save meal to database
    func saveMeal(context: ModelContext) -> Meal? {
        guard !nutritionInfo.isEmpty else { return nil }
        
        let meal = Meal(
            mealType: mealType,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8),
            totalCalories: totalCalories,
            isAnalyzed: true
        )
        
        // Create food items
        for (index, nutrition) in nutritionInfo.enumerated() {
            let confidence = index < recognizedFoods.count ? recognizedFoods[index].confidence : 0.8
            let foodItem = FoodItem(
                name: nutrition.food,
                calories: nutrition.calories,
                protein: nutrition.protein,
                carbohydrates: nutrition.carbohydrates,
                fat: nutrition.fat,
                fiber: nutrition.fiber,
                sugar: nutrition.sugar,
                portionSize: nutrition.portionSize,
                confidence: confidence
            )
            meal.foodItems.append(foodItem)
        }
        
        // Add exercise suggestions
        for suggestion in exerciseSuggestions.prefix(8) {
            let exerciseSuggestion = ExerciseSuggestion(
                exerciseType: suggestion.exerciseType,
                durationMinutes: suggestion.durationMinutes,
                caloriesBurned: suggestion.caloriesBurned
            )
            meal.exerciseSuggestions.append(exerciseSuggestion)
        }
        
        // Add LLM advice
        if let advice = fitnessAdvice {
            meal.llmAdvice = advice.summary
        }
        
        context.insert(meal)
        
        do {
            try context.save()
            return meal
        } catch {
            errorMessage = "Failed to save meal: \(error.localizedDescription)"
            showError = true
            return nil
        }
    }
    
    /// Reset the view model for a new analysis
    func reset() {
        selectedImage = nil
        selectedPhotoItem = nil
        recognizedFoods = []
        nutritionInfo = []
        exerciseSuggestions = []
        fitnessAdvice = nil
        analysisProgress = 0.0
        analysisStage = .idle
        showResults = false
        errorMessage = nil
    }
}

// MARK: - Analysis Stage Enum

enum AnalysisStage: String {
    case idle = "Ready"
    case recognizing = "Recognizing food..."
    case fetchingNutrition = "Fetching nutrition data..."
    case calculatingExercise = "Calculating exercise..."
    case generatingAdvice = "Generating advice..."
    case complete = "Complete!"
    case error = "Error"
    
    var icon: String {
        switch self {
        case .idle: return "camera"
        case .recognizing: return "eye"
        case .fetchingNutrition: return "leaf"
        case .calculatingExercise: return "figure.run"
        case .generatingAdvice: return "brain"
        case .complete: return "checkmark.circle"
        case .error: return "exclamationmark.triangle"
        }
    }
}
