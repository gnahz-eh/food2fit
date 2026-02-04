//
//  OnboardingViewModel.swift
//  food2fit
//
//  ViewModel for user onboarding flow
//

import Foundation
import SwiftUI
import SwiftData

/// View model for the onboarding flow
@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentStep: OnboardingStep = .welcome
    @Published var name: String = ""
    @Published var age: String = "30"
    @Published var weightKg: String = "70"
    @Published var heightCm: String = "170"
    @Published var biologicalSex: BiologicalSex = .male
    @Published var fitnessGoal: FitnessGoal = .generalHealth
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Computed Properties
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .basicInfo:
            return !name.isEmpty && isValidAge && isValidWeight && isValidHeight
        case .fitnessGoals:
            return true
        case .activityLevel:
            return true
        case .complete:
            return true
        }
    }
    
    var isValidAge: Bool {
        guard let ageValue = Int(age) else { return false }
        return ageValue >= 13 && ageValue <= 120
    }
    
    var isValidWeight: Bool {
        guard let weight = Double(weightKg) else { return false }
        return weight >= 20 && weight <= 500
    }
    
    var isValidHeight: Bool {
        guard let height = Double(heightCm) else { return false }
        return height >= 50 && height <= 300
    }
    
    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    // MARK: - Methods
    
    func nextStep() {
        guard canProceed else { return }
        
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = next
            }
        }
    }
    
    func previousStep() {
        if let previous = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = previous
            }
        }
    }
    
    func createUserProfile(context: ModelContext) -> UserProfile {
        let profile = UserProfile(
            name: name,
            age: Int(age) ?? 30,
            weightKg: Double(weightKg) ?? 70,
            heightCm: Double(heightCm) ?? 170,
            biologicalSex: biologicalSex,
            fitnessGoal: fitnessGoal,
            activityLevel: activityLevel,
            hasCompletedOnboarding: true
        )
        
        context.insert(profile)
        
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
            showError = true
        }
        
        return profile
    }
}

// MARK: - Onboarding Step Enum

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case basicInfo = 1
    case fitnessGoals = 2
    case activityLevel = 3
    case complete = 4
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .basicInfo: return "About You"
        case .fitnessGoals: return "Your Goals"
        case .activityLevel: return "Activity Level"
        case .complete: return "All Set!"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome: return "Let's get started on your fitness journey"
        case .basicInfo: return "Tell us a bit about yourself"
        case .fitnessGoals: return "What are you working towards?"
        case .activityLevel: return "How active are you?"
        case .complete: return "You're ready to go"
        }
    }
}
