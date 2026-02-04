//
//  Meal.swift
//  food2fit
//
//  Data model for meal entries
//

import Foundation
import SwiftData

/// Represents a meal type
enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "carrot"
        }
    }
    
    var description: String { rawValue }
}

/// Represents a complete meal entry
@Model
final class Meal {
    var id: UUID
    var mealType: MealType
    var imageData: Data?
    var timestamp: Date
    var totalCalories: Int
    var notes: String?
    
    @Relationship(deleteRule: .cascade)
    var foodItems: [FoodItem]
    
    @Relationship(deleteRule: .cascade)
    var exerciseSuggestions: [ExerciseSuggestion]
    
    var llmAdvice: String?
    var isAnalyzed: Bool
    
    init(
        id: UUID = UUID(),
        mealType: MealType = .lunch,
        imageData: Data? = nil,
        timestamp: Date = Date(),
        totalCalories: Int = 0,
        notes: String? = nil,
        foodItems: [FoodItem] = [],
        exerciseSuggestions: [ExerciseSuggestion] = [],
        llmAdvice: String? = nil,
        isAnalyzed: Bool = false
    ) {
        self.id = id
        self.mealType = mealType
        self.imageData = imageData
        self.timestamp = timestamp
        self.totalCalories = totalCalories
        self.notes = notes
        self.foodItems = foodItems
        self.exerciseSuggestions = exerciseSuggestions
        self.llmAdvice = llmAdvice
        self.isAnalyzed = isAnalyzed
    }
    
    /// Recalculate total calories from food items
    func recalculateTotalCalories() {
        totalCalories = foodItems.reduce(0) { $0 + $1.calories }
    }
}

/// Represents individual food items identified in a meal
@Model
final class FoodItem {
    var id: UUID
    var name: String
    var calories: Int
    var protein: Double? // grams
    var carbohydrates: Double? // grams
    var fat: Double? // grams
    var fiber: Double? // grams
    var sugar: Double? // grams
    var portionSize: String?
    var confidence: Double // 0-1 confidence score from ML model
    
    @Relationship(inverse: \Meal.foodItems)
    var meal: Meal?
    
    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        protein: Double? = nil,
        carbohydrates: Double? = nil,
        fat: Double? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        portionSize: String? = nil,
        confidence: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.portionSize = portionSize
        self.confidence = confidence
    }
}

/// Represents an exercise suggestion for burning calories
@Model
final class ExerciseSuggestion {
    var id: UUID
    var exerciseType: ExerciseType
    var durationMinutes: Int
    var caloriesBurned: Int
    
    @Relationship(inverse: \Meal.exerciseSuggestions)
    var meal: Meal?
    
    init(
        id: UUID = UUID(),
        exerciseType: ExerciseType,
        durationMinutes: Int,
        caloriesBurned: Int
    ) {
        self.id = id
        self.exerciseType = exerciseType
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
    }
    
    /// Format duration as human readable string
    var formattedDuration: String {
        if durationMinutes >= 60 {
            let hours = durationMinutes / 60
            let minutes = durationMinutes % 60
            if minutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(minutes)m"
        }
        return "\(durationMinutes) min"
    }
}
