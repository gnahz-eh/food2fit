//
//  ExerciseConversionService.swift
//  food2fit
//
//  Service for converting calories to exercise time
//

import Foundation

/// Service for converting calories to exercise duration based on user profile
final class ExerciseConversionService {
    
    /// Shared instance for convenience
    static let shared = ExerciseConversionService()
    
    private init() {}
    
    /// Calculate exercise suggestions for burning given calories
    /// - Parameters:
    ///   - calories: Number of calories to burn
    ///   - userWeight: User's weight in kg
    ///   - exerciseTypes: Types of exercises to include (defaults to all)
    /// - Returns: Array of ExerciseSuggestion sorted by duration
    func calculateExerciseSuggestions(
        for calories: Int,
        userWeight: Double,
        exerciseTypes: [ExerciseType] = ExerciseType.allCases
    ) -> [ExerciseSuggestion] {
        
        var suggestions: [ExerciseSuggestion] = []
        
        for exerciseType in exerciseTypes {
            let minutes = exerciseType.minutesToBurn(calories: calories, weightKg: userWeight)
            
            // Calculate actual calories burned (may be slightly different due to rounding)
            let actualCaloriesBurned = Int(exerciseType.caloriesPerMinute(weightKg: userWeight) * Double(minutes))
            
            let suggestion = ExerciseSuggestion(
                exerciseType: exerciseType,
                durationMinutes: minutes,
                caloriesBurned: actualCaloriesBurned
            )
            suggestions.append(suggestion)
        }
        
        // Sort by duration (shortest first)
        return suggestions.sorted { $0.durationMinutes < $1.durationMinutes }
    }
    
    /// Get a quick summary of exercise time for primary exercises
    /// - Parameters:
    ///   - calories: Number of calories to burn
    ///   - userWeight: User's weight in kg
    /// - Returns: Dictionary of exercise type to minutes
    func quickExerciseSummary(
        for calories: Int,
        userWeight: Double
    ) -> [ExerciseType: Int] {
        let primaryExercises: [ExerciseType] = [.running, .walking, .cycling, .swimming]
        var summary: [ExerciseType: Int] = [:]
        
        for exercise in primaryExercises {
            summary[exercise] = exercise.minutesToBurn(calories: calories, weightKg: userWeight)
        }
        
        return summary
    }
    
    /// Format exercise time as a user-friendly string
    /// - Parameter minutes: Duration in minutes
    /// - Returns: Formatted string like "30 min" or "1h 15m"
    func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(hours) hour\(hours > 1 ? "s" : "")"
            }
            return "\(hours)h \(mins)m"
        }
        return "\(minutes) min"
    }
    
    /// Generate a motivational message based on exercise time
    /// - Parameters:
    ///   - exerciseType: Type of exercise
    ///   - minutes: Duration in minutes
    /// - Returns: Motivational string
    func motivationalMessage(for exerciseType: ExerciseType, minutes: Int) -> String {
        switch exerciseType {
        case .running:
            if minutes <= 15 {
                return "A quick run around the block!"
            } else if minutes <= 30 {
                return "A nice morning jog"
            } else {
                return "A solid running session"
            }
        case .walking:
            if minutes <= 20 {
                return "A short walk in the park"
            } else if minutes <= 45 {
                return "A pleasant stroll"
            } else {
                return "A long scenic walk"
            }
        case .cycling:
            if minutes <= 20 {
                return "A quick bike ride"
            } else if minutes <= 40 {
                return "A leisurely cycle"
            } else {
                return "An adventurous bike trip"
            }
        case .swimming:
            if minutes <= 20 {
                return "A refreshing swim"
            } else if minutes <= 40 {
                return "Good pool time"
            } else {
                return "Serious lap swimming"
            }
        default:
            if minutes <= 15 {
                return "Quick \(exerciseType.rawValue.lowercased()) session"
            } else if minutes <= 30 {
                return "Good \(exerciseType.rawValue.lowercased()) workout"
            } else {
                return "Solid \(exerciseType.rawValue.lowercased()) session"
            }
        }
    }
}
