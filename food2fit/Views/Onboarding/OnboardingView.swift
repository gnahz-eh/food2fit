//
//  OnboardingView.swift
//  food2fit
//
//  User onboarding flow
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            if viewModel.currentStep != .welcome {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            
            // Content
            TabView(selection: $viewModel.currentStep) {
                WelcomeStepView(viewModel: viewModel)
                    .tag(OnboardingStep.welcome)
                
                BasicInfoStepView(viewModel: viewModel)
                    .tag(OnboardingStep.basicInfo)
                
                FitnessGoalsStepView(viewModel: viewModel)
                    .tag(OnboardingStep.fitnessGoals)
                
                ActivityLevelStepView(viewModel: viewModel)
                    .tag(OnboardingStep.activityLevel)
                
                CompleteStepView(viewModel: viewModel) {
                    completeOnboarding()
                }
                .tag(OnboardingStep.complete)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func completeOnboarding() {
        let _ = viewModel.createUserProfile(context: modelContext)
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App icon/logo
            ZStack {
                Circle()
                    .fill(LinearGradient.appGradient)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text("Welcome to food2fit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Transform your meals into actionable fitness goals")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "camera", color: .blue, title: "Snap Your Meal", description: "Take a photo of your food")
                FeatureRow(icon: "chart.bar", color: .orange, title: "Get Insights", description: "See calories and nutrition")
                FeatureRow(icon: "figure.run", color: .green, title: "Exercise Guide", description: "Know how to burn it off")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Button
            PrimaryButton("Get Started", icon: "arrow.right") {
                viewModel.nextStep()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Basic Info Step

struct BasicInfoStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name
        case age
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(viewModel.currentStep.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(viewModel.currentStep.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Form fields
                VStack(spacing: 20) {
                    FormField(
                        title: "Your Name",
                        text: $viewModel.name,
                        placeholder: "Enter your name",
                        focusedField: $focusedField,
                        fieldIdentifier: Field.name
                    )

                    FormField(
                        title: "Age",
                        text: $viewModel.age,
                        placeholder: "30",
                        keyboardType: .numberPad,
                        isValid: viewModel.isValidAge,
                        errorMessage: "Age must be between 13 and 120",
                        focusedField: $focusedField,
                        fieldIdentifier: Field.age
                    )

                    // Weight Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Weight (kg)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Picker("Weight", selection: $viewModel.selectedWeight) {
                            ForEach(Array(stride(from: 20.0, through: 200.0, by: 0.5)), id: \.self) { weight in
                                Text(String(format: "%.1f kg", weight)).tag(weight)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(10)
                    }

                    // Height Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Height (cm)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Picker("Height", selection: $viewModel.selectedHeight) {
                            ForEach(Array(stride(from: 50.0, through: 250.0, by: 1.0)), id: \.self) { height in
                                Text(String(format: "%.0f cm", height)).tag(height)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .background(Color.appSecondaryBackground)
                        .cornerRadius(10)
                    }

                    // Biological Sex Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Biological Sex")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Picker("Biological Sex", selection: $viewModel.biologicalSex) {
                            ForEach(BiologicalSex.allCases, id: \.self) { sex in
                                Text(sex.description).tag(sex)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
                
                // Navigation buttons
                HStack(spacing: 12) {
                    SecondaryButton("Back", icon: "arrow.left") {
                        viewModel.previousStep()
                    }
                    
                    PrimaryButton("Continue", icon: "arrow.right", isEnabled: viewModel.canProceed) {
                        viewModel.nextStep()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - Fitness Goals Step

struct FitnessGoalsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(viewModel.currentStep.title)
                    .font(.title)
                    .fontWeight(.bold)
                Text(viewModel.currentStep.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Goal options
            VStack(spacing: 12) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    GoalOptionCard(
                        goal: goal,
                        isSelected: viewModel.fitnessGoal == goal
                    ) {
                        viewModel.fitnessGoal = goal
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 12) {
                SecondaryButton("Back", icon: "arrow.left") {
                    viewModel.previousStep()
                }
                
                PrimaryButton("Continue", icon: "arrow.right") {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct GoalOptionCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color.goalColor(for: goal))
                    .frame(width: 44, height: 44)
                    .background(isSelected ? Color.goalColor(for: goal) : Color.goalColor(for: goal).opacity(0.15))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.description)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(goalSubtitle(for: goal))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.appSecondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private func goalSubtitle(for goal: FitnessGoal) -> String {
        switch goal {
        case .weightLoss: return "Reduce calories and increase activity"
        case .muscleGain: return "Build strength and muscle mass"
        case .maintenance: return "Keep your current weight stable"
        case .generalHealth: return "Improve overall wellness"
        }
    }
}

// MARK: - Activity Level Step

struct ActivityLevelStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(viewModel.currentStep.title)
                    .font(.title)
                    .fontWeight(.bold)
                Text(viewModel.currentStep.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Activity level options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        ActivityLevelCard(
                            level: level,
                            isSelected: viewModel.activityLevel == level
                        ) {
                            viewModel.activityLevel = level
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Navigation buttons
            HStack(spacing: 12) {
                SecondaryButton("Back", icon: "arrow.left") {
                    viewModel.previousStep()
                }
                
                PrimaryButton("Continue", icon: "arrow.right") {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.description)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(level.detailedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.appSecondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Complete Step

struct CompleteStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()

                // Success animation
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 140, height: 140)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                }

                VStack(spacing: 16) {
                    Text("You're All Set!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Welcome, \(viewModel.name)! Your personalized fitness journey begins now.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Summary card
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        SummaryRow(label: "Goal", value: viewModel.fitnessGoal.description)
                        SummaryRow(label: "Activity", value: viewModel.activityLevel.description)

                        let bmi = viewModel.selectedWeight / pow(viewModel.selectedHeight / 100, 2)
                        SummaryRow(label: "BMI", value: String(format: "%.1f", bmi))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Complete button
                PrimaryButton("Start Using food2fit", icon: "arrow.right") {
                    viewModel.startOnboarding {
                        onComplete()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .blur(radius: viewModel.isLoading ? 3 : 0)
            .disabled(viewModel.isLoading)

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    ProgressRing(
                        progress: viewModel.loadingProgress,
                        lineWidth: 8,
                        color: .accentColor
                    )
                    .frame(width: 100, height: 100)

                    Text(viewModel.loadingMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(40)
                .background(Color.appSecondaryBackground)
                .cornerRadius(20)
                .shadow(radius: 20)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
