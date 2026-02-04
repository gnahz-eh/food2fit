//
//  ProfileViewModel.swift
//  food2fit
//
//  ViewModel for user profile management
//

import Foundation
import SwiftUI
import SwiftData

/// View model for user profile screen
@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var weightKg: String = ""
    @Published var heightCm: String = ""
    @Published var biologicalSex: BiologicalSex = .male
    @Published var fitnessGoal: FitnessGoal = .generalHealth
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    
    @Published var isEditing: Bool = false
    @Published var isSaving: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    @Published var showSaveSuccess: Bool = false
    
    // MARK: - Computed Properties
    
    var bmi: Double {
        guard let weight = Double(weightKg),
              let height = Double(heightCm),
              height > 0 else { return 0 }
        return weight / pow(height / 100, 2)
    }
    
    var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    var bmiColor: Color {
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    var estimatedBMR: Int {
        guard let weight = Double(weightKg),
              let height = Double(heightCm),
              let ageValue = Int(age) else { return 0 }
        
        let baseBMR: Double
        switch biologicalSex {
        case .male:
            baseBMR = (10 * weight) + (6.25 * height) - (5 * Double(ageValue)) + 5
        case .female:
            baseBMR = (10 * weight) + (6.25 * height) - (5 * Double(ageValue)) - 161
        case .other:
            let maleBMR = (10 * weight) + (6.25 * height) - (5 * Double(ageValue)) + 5
            let femaleBMR = (10 * weight) + (6.25 * height) - (5 * Double(ageValue)) - 161
            baseBMR = (maleBMR + femaleBMR) / 2
        }
        return Int(baseBMR)
    }
    
    var estimatedTDEE: Int {
        return Int(Double(estimatedBMR) * activityLevel.multiplier)
    }
    
    var dailyCalorieTarget: Int {
        let tdee = estimatedTDEE
        switch fitnessGoal {
        case .weightLoss: return Int(Double(tdee) * 0.8)
        case .muscleGain: return Int(Double(tdee) * 1.1)
        case .maintenance, .generalHealth: return tdee
        }
    }
    
    var isValidInput: Bool {
        guard !name.isEmpty else { return false }
        guard let ageValue = Int(age), ageValue >= 13, ageValue <= 120 else { return false }
        guard let weight = Double(weightKg), weight >= 20, weight <= 500 else { return false }
        guard let height = Double(heightCm), height >= 50, height <= 300 else { return false }
        return true
    }
    
    // MARK: - Private Properties
    
    private var profile: UserProfile?
    
    // MARK: - Methods
    
    /// Load profile data
    func loadProfile(_ profile: UserProfile?) {
        guard let profile = profile else { return }
        
        self.profile = profile
        name = profile.name
        age = String(profile.age)
        weightKg = String(format: "%.1f", profile.weightKg)
        heightCm = String(format: "%.1f", profile.heightCm)
        biologicalSex = profile.biologicalSex
        fitnessGoal = profile.fitnessGoal
        activityLevel = profile.activityLevel
    }
    
    /// Save profile changes
    func saveProfile(context: ModelContext) {
        guard isValidInput else {
            errorMessage = "Please check your input values"
            showError = true
            return
        }
        
        guard let profile = profile else {
            errorMessage = "Profile not found"
            showError = true
            return
        }
        
        isSaving = true
        
        profile.name = name
        profile.age = Int(age) ?? 30
        profile.weightKg = Double(weightKg) ?? 70
        profile.heightCm = Double(heightCm) ?? 170
        profile.biologicalSex = biologicalSex
        profile.fitnessGoal = fitnessGoal
        profile.activityLevel = activityLevel
        profile.updatedAt = Date()
        
        do {
            try context.save()
            isEditing = false
            showSaveSuccess = true
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
            showError = true
        }
        
        isSaving = false
    }
    
    /// Cancel editing
    func cancelEditing() {
        loadProfile(profile)
        isEditing = false
    }
    
    /// Get profile statistics
    func getProfileStats() -> [ProfileStat] {
        return [
            ProfileStat(title: "BMI", value: String(format: "%.1f", bmi), subtitle: bmiCategory, color: bmiColor),
            ProfileStat(title: "BMR", value: "\(estimatedBMR)", subtitle: "kcal/day", color: .orange),
            ProfileStat(title: "TDEE", value: "\(estimatedTDEE)", subtitle: "kcal/day", color: .blue),
            ProfileStat(title: "Target", value: "\(dailyCalorieTarget)", subtitle: "kcal/day", color: .green)
        ]
    }
}

// MARK: - Supporting Types

struct ProfileStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let color: Color
}
