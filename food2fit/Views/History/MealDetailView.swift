//
//  MealDetailView.swift
//  food2fit
//
//  Detailed view of a single meal
//

import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    
    @State private var selectedTab: DetailTab = .nutrition
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Meal image
                mealImageSection
                
                // Summary stats
                summaryStatsSection
                
                // Tab selection
                Picker("Detail View", selection: $selectedTab) {
                    Text("Nutrition").tag(DetailTab.nutrition)
                    Text("Exercise").tag(DetailTab.exercise)
                    Text("Advice").tag(DetailTab.advice)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Tab content
                switch selectedTab {
                case .nutrition:
                    nutritionSection
                case .exercise:
                    exerciseSection
                case .advice:
                    adviceSection
                }
            }
        }
        .navigationTitle(meal.mealType.description)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Meal Image Section
    
    private var mealImageSection: some View {
        Group {
            if let imageData = meal.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: meal.mealType.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                    }
            }
        }
    }
    
    // MARK: - Summary Stats Section
    
    private var summaryStatsSection: some View {
        HStack(spacing: 0) {
            StatItem(value: "\(meal.totalCalories)", label: "Calories", color: .orange)
            Divider().frame(height: 40)
            StatItem(value: "\(meal.foodItems.count)", label: "Items", color: .blue)
            Divider().frame(height: 40)
            StatItem(value: formatTime(meal.timestamp), label: "Time", color: .green)
        }
        .padding(.vertical, 12)
        .background(Color.appSecondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Nutrition Section
    
    private var nutritionSection: some View {
        VStack(spacing: 16) {
            ForEach(meal.foodItems) { foodItem in
                FoodItemCard(foodItem: foodItem)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Exercise Section
    
    private var exerciseSection: some View {
        VStack(spacing: 12) {
            Text("Exercise to Burn \(meal.totalCalories) kcal")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ForEach(meal.exerciseSuggestions) { suggestion in
                ExerciseSuggestionCard(suggestion: suggestion)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Advice Section
    
    private var adviceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let advice = meal.llmAdvice {
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("AI Insights", systemImage: "brain")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        
                        Text(advice)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                CardView {
                    VStack(spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("No personalized advice available for this meal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Tab Enum

enum DetailTab {
    case nutrition
    case exercise
    case advice
}

// MARK: - Stat Item

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Food Item Card

struct FoodItemCard: View {
    let foodItem: FoodItem
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(foodItem.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(foodItem.calories) kcal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                if let portion = foodItem.portionSize {
                    Text(portion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Macros
                if foodItem.protein != nil || foodItem.carbohydrates != nil || foodItem.fat != nil {
                    HStack(spacing: 16) {
                        if let protein = foodItem.protein {
                            MacroLabel(value: protein, label: "Protein", color: .blue)
                        }
                        if let carbs = foodItem.carbohydrates {
                            MacroLabel(value: carbs, label: "Carbs", color: .purple)
                        }
                        if let fat = foodItem.fat {
                            MacroLabel(value: fat, label: "Fat", color: .yellow)
                        }
                    }
                }
                
                // Confidence indicator
                HStack {
                    Text("Recognition confidence")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: foodItem.confidence)
                        .tint(confidenceColor)
                    
                    Text("\(Int(foodItem.confidence * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var confidenceColor: Color {
        switch foodItem.confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .yellow
        default: return .orange
        }
    }
}

// MARK: - Macro Label

struct MacroLabel: View {
    let value: Double
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1fg", value))
                .font(.caption)
                .fontWeight(.medium)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(6)
    }
}

// MARK: - Exercise Suggestion Card

struct ExerciseSuggestionCard: View {
    let suggestion: ExerciseSuggestion
    
    var body: some View {
        CardView(padding: 12) {
            HStack(spacing: 12) {
                Image(systemName: suggestion.exerciseType.icon)
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 44, height: 44)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.exerciseType.description)
                        .font(.headline)
                    
                    Text("\(suggestion.exerciseType.intensity.rawValue) intensity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(suggestion.formattedDuration)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("\(suggestion.caloriesBurned) kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MealDetailView(meal: Meal(
            mealType: .lunch,
            totalCalories: 650,
            foodItems: [
                FoodItem(name: "Hamburger", calories: 450, protein: 25, carbohydrates: 35, fat: 22),
                FoodItem(name: "French Fries", calories: 200, protein: 3, carbohydrates: 28, fat: 10)
            ]
        ))
    }
}
