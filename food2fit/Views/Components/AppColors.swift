//
//  AppColors.swift
//  food2fit
//
//  App-wide color definitions
//

import SwiftUI

extension Color {
    // Primary colors
    static let appPrimary = Color("AccentColor")
    static let appSecondary = Color.blue.opacity(0.8)
    
    // Semantic colors
    static let appBackground = Color(UIColor.systemBackground)
    static let appSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let appTertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // Custom colors for the app
    static let calorieOrange = Color.orange
    static let exerciseGreen = Color.green
    static let proteinBlue = Color.blue
    static let carbsPurple = Color.purple
    static let fatYellow = Color.yellow
    
    // Gradient colors
    static let gradientStart = Color(red: 0.2, green: 0.6, blue: 0.9)
    static let gradientEnd = Color(red: 0.4, green: 0.8, blue: 0.6)
    
    // Fitness goal colors
    static func goalColor(for goal: FitnessGoal) -> Color {
        switch goal {
        case .weightLoss: return .orange
        case .muscleGain: return .blue
        case .maintenance: return .green
        case .generalHealth: return .purple
        }
    }
    
    // Exercise intensity colors
    static func intensityColor(for intensity: ExerciseIntensity) -> Color {
        switch intensity {
        case .low: return .green
        case .moderate: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Gradients

extension LinearGradient {
    static let appGradient = LinearGradient(
        colors: [Color.gradientStart, Color.gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let calorieGradient = LinearGradient(
        colors: [Color.orange, Color.red],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let exerciseGradient = LinearGradient(
        colors: [Color.green, Color.blue],
        startPoint: .leading,
        endPoint: .trailing
    )
}
