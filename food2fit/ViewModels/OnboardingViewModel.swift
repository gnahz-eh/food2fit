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
    @Published var selectedWeight: Double = 70.0
    @Published var selectedHeight: Double = 170.0
    @Published var biologicalSex: BiologicalSex = .male
    @Published var fitnessGoal: FitnessGoal = .generalHealth
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    
    @Published var isLoading: Bool = false
    @Published var loadingProgress: Double = 0.0
    @Published var loadingMessage: String = ""
    @Published var errorMessage: String?
    @Published var showError: Bool = false

    // MARK: - Loading Messages

    private let loadingMessages: [(progress: Double, message: String)] = [
        (0.1, "Setting up your profile..."),
        (0.3, "Calculating your daily goals..."),
        (0.5, "Preparing your nutrition plan..."),
        (0.7, "Customizing your experience..."),
        (0.9, "Almost there..."),
        (1.0, "Welcome aboard!")
    ]
    
    // MARK: - Computed Properties
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .basicInfo:
            return !name.isEmpty && isValidAge
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
        return selectedWeight >= 20 && selectedWeight <= 500
    }

    var isValidHeight: Bool {
        return selectedHeight >= 50 && selectedHeight <= 300
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
            weightKg: selectedWeight,
            heightCm: selectedHeight,
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

    func startOnboarding(completion: @escaping () -> Void) {
        isLoading = true
        loadingProgress = 0.0

        Task {
            for step in loadingMessages {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        loadingProgress = step.progress
                        loadingMessage = step.message
                    }
                }
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }

            await MainActor.run {
                isLoading = false
                completion()
            }
        }
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
