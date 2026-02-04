//
//  MealAnalysisResultsView.swift
//  food2fit
//
//  View displaying meal analysis results
//

import SwiftUI

struct MealAnalysisResultsView: View {
    @ObservedObject var viewModel: MealAnalysisViewModel
    let userProfile: UserProfile?
    let onSave: () -> Void
    let onNewMeal: () -> Void
    
    @State private var selectedTab: ResultsTab = .overview
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selection
            Picker("Results Tab", selection: $selectedTab) {
                Text("Overview").tag(ResultsTab.overview)
                Text("Exercise").tag(ResultsTab.exercise)
                Text("Advice").tag(ResultsTab.advice)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab content
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedTab {
                    case .overview:
                        overviewContent
                    case .exercise:
                        exerciseContent
                    case .advice:
                        adviceContent
                    }
                }
                .padding()
            }
            
            // Action buttons
            VStack(spacing: 12) {
                PrimaryButton("Save Meal", icon: "checkmark.circle") {
                    onSave()
                }
                
                SecondaryButton("Log Another Meal", icon: "plus") {
                    onNewMeal()
                }
            }
            .padding()
            .background(Color.appBackground)
        }
    }
    
    // MARK: - Overview Content
    
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Meal image
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
            }
            
            // Total calories card
            CardView {
                VStack(spacing: 8) {
                    Text("Total Calories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.totalCalories)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("kcal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            // Food items
            VStack(alignment: .leading, spacing: 12) {
                Text("Recognized Foods")
                    .font(.headline)
                
                ForEach(Array(zip(viewModel.recognizedFoods, viewModel.nutritionInfo)), id: \.0.foodName) { (food, nutrition) in
                    RecognizedFoodRow(food: food, nutrition: nutrition)
                }
            }
            
            // Macros summary
            if let firstNutrition = viewModel.nutritionInfo.first,
               firstNutrition.protein != nil {
                macrosSummaryCard
            }
        }
    }
    
    private var macrosSummaryCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Macronutrients")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    MacroCircle(
                        value: viewModel.nutritionInfo.compactMap { $0.protein }.reduce(0, +),
                        label: "Protein",
                        color: .blue
                    )
                    
                    MacroCircle(
                        value: viewModel.nutritionInfo.compactMap { $0.carbohydrates }.reduce(0, +),
                        label: "Carbs",
                        color: .purple
                    )
                    
                    MacroCircle(
                        value: viewModel.nutritionInfo.compactMap { $0.fat }.reduce(0, +),
                        label: "Fat",
                        color: .yellow
                    )
                }
            }
        }
    }
    
    // MARK: - Exercise Content
    
    private var exerciseContent: some View {
        VStack(spacing: 20) {
            // Header
            CardView {
                VStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("To burn \(viewModel.totalCalories) kcal")
                        .font(.headline)
                    
                    Text("Based on your weight of \(Int(userProfile?.weightKg ?? 70)) kg")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            // Exercise options
            ForEach(viewModel.exerciseSuggestions) { suggestion in
                ExerciseOptionCard(suggestion: suggestion)
            }
        }
    }
    
    // MARK: - Advice Content
    
    private var adviceContent: some View {
        VStack(spacing: 20) {
            if let advice = viewModel.fitnessAdvice {
                // Summary
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Summary", systemImage: "text.quote")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        
                        Text(advice.summary)
                            .font(.body)
                    }
                }
                
                // Exercise suggestions
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Exercise Tips", systemImage: "figure.run")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        ForEach(advice.exerciseSuggestions, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(tip)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Meal suggestions
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Meal Suggestions", systemImage: "leaf")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        ForEach(advice.mealSuggestions, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(tip)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Health tips
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Health Tips", systemImage: "heart")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        ForEach(advice.healthTips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(tip)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                // Motivational message
                CardView {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundColor(.purple)
                        
                        Text(advice.motivationalMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            } else {
                EmptyStateView(
                    icon: "brain",
                    title: "No Advice Available",
                    message: "Personalized advice could not be generated at this time."
                )
            }
        }
    }
}

// MARK: - Results Tab Enum

enum ResultsTab {
    case overview
    case exercise
    case advice
}

// MARK: - Recognized Food Row

struct RecognizedFoodRow: View {
    let food: FoodRecognitionResult
    let nutrition: NutritionInfo
    
    @State private var isExpanded = false
    
    var body: some View {
        CardView(padding: 12) {
            VStack(spacing: 12) {
                // Main row
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.foodName)
                            .font(.headline)
                        
                        if let portion = nutrition.portionSize {
                            Text(portion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(nutrition.calories) kcal")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Text("\(Int(food.confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Expanded content
                if isExpanded {
                    Divider()
                    
                    HStack(spacing: 16) {
                        if let protein = nutrition.protein {
                            MiniMacro(label: "Protein", value: "\(Int(protein))g", color: .blue)
                        }
                        if let carbs = nutrition.carbohydrates {
                            MiniMacro(label: "Carbs", value: "\(Int(carbs))g", color: .purple)
                        }
                        if let fat = nutrition.fat {
                            MiniMacro(label: "Fat", value: "\(Int(fat))g", color: .yellow)
                        }
                    }
                    
                    if let tips = nutrition.healthTips {
                        Text(tips)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

struct MiniMacro: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Macro Circle

struct MacroCircle: View {
    let value: Double
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: min(value / 100, 1))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(value))g")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Exercise Option Card

struct ExerciseOptionCard: View {
    let suggestion: ExerciseSuggestion
    
    var body: some View {
        CardView(padding: 16) {
            HStack(spacing: 16) {
                // Exercise icon
                ZStack {
                    Circle()
                        .fill(intensityColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: suggestion.exerciseType.icon)
                        .font(.title2)
                        .foregroundColor(intensityColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.exerciseType.description)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Label(suggestion.exerciseType.intensity.rawValue, systemImage: "bolt")
                            .font(.caption)
                            .foregroundColor(intensityColor)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(suggestion.caloriesBurned) kcal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(suggestion.formattedDuration)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
    }
    
    private var intensityColor: Color {
        Color.intensityColor(for: suggestion.exerciseType.intensity)
    }
}

// MARK: - Preview

#Preview {
    MealAnalysisResultsView(
        viewModel: MealAnalysisViewModel(),
        userProfile: nil,
        onSave: {},
        onNewMeal: {}
    )
}
