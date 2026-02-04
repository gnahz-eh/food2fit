//
//  UserProfile.swift
//  food2fit
//
//  Data model for user profile information
//

import Foundation
import SwiftData

/// Represents the user's fitness goals
enum FitnessGoal: String, Codable, CaseIterable {
    case weightLoss = "Weight Loss"
    case muscleGain = "Muscle Gain"
    case maintenance = "Maintenance"
    case generalHealth = "General Health"
    
    var description: String { rawValue }
    
    var icon: String {
        switch self {
        case .weightLoss: return "arrow.down.circle"
        case .muscleGain: return "dumbbell"
        case .maintenance: return "equal.circle"
        case .generalHealth: return "heart.circle"
        }
    }
}

/// Represents the user's activity level
enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extraActive = "Extra Active"
    
    var description: String { rawValue }
    
    /// Activity multiplier for calorie calculations
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .lightlyActive: return "Light exercise 1-3 days/week"
        case .moderatelyActive: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Hard exercise 6-7 days/week"
        case .extraActive: return "Very hard exercise & physical job"
        }
    }
}

/// Represents biological sex for calorie calculations
enum BiologicalSex: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var description: String { rawValue }
}

/// User profile model persisted with SwiftData
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var email: String?
    var age: Int
    var weightKg: Double
    var heightCm: Double
    var biologicalSex: BiologicalSex
    var fitnessGoal: FitnessGoal
    var activityLevel: ActivityLevel
    var createdAt: Date
    var updatedAt: Date
    var hasCompletedOnboarding: Bool
    
    // Daily calorie target based on goals
    var dailyCalorieTarget: Int {
        let bmr = calculateBMR()
        let tdee = bmr * activityLevel.multiplier
        
        switch fitnessGoal {
        case .weightLoss:
            return Int(tdee * 0.8) // 20% deficit
        case .muscleGain:
            return Int(tdee * 1.1) // 10% surplus
        case .maintenance, .generalHealth:
            return Int(tdee)
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String = "",
        email: String? = nil,
        age: Int = 30,
        weightKg: Double = 70.0,
        heightCm: Double = 170.0,
        biologicalSex: BiologicalSex = .male,
        fitnessGoal: FitnessGoal = .generalHealth,
        activityLevel: ActivityLevel = .moderatelyActive,
        hasCompletedOnboarding: Bool = false
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.biologicalSex = biologicalSex
        self.fitnessGoal = fitnessGoal
        self.activityLevel = activityLevel
        self.createdAt = Date()
        self.updatedAt = Date()
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
    
    /// Calculate Basal Metabolic Rate using Mifflin-St Jeor equation
    func calculateBMR() -> Double {
        let baseBMR: Double
        switch biologicalSex {
        case .male:
            baseBMR = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
        case .female:
            baseBMR = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
        case .other:
            // Use average of male and female formulas
            let maleBMR = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) + 5
            let femaleBMR = (10 * weightKg) + (6.25 * heightCm) - (5 * Double(age)) - 161
            baseBMR = (maleBMR + femaleBMR) / 2
        }
        return baseBMR
    }
    
    /// Calculate Total Daily Energy Expenditure
    func calculateTDEE() -> Double {
        return calculateBMR() * activityLevel.multiplier
    }
}
