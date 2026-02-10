//
//  food2fitApp.swift
//  food2fit
//
//  Created by zhanghe on 2026/2/1.
//

import SwiftUI
import SwiftData

@main
struct food2fitApp: App {
    
    /// Shared model container for SwiftData persistence
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Meal.self,
            FoodItem.self,
            ExerciseSuggestion.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Configure API services with stored API key if available
        configureAPIServices()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    /// Configure API services with stored credentials
    private func configureAPIServices() {
        if let apiKey = UserDefaults.standard.string(forKey: "openai_api_key"),
           !apiKey.isEmpty {
            let endpoint = UserDefaults.standard.string(forKey: "api_endpoint") ?? "https://api.openai.com/v1/chat/completions"
            let model = UserDefaults.standard.string(forKey: "model_name") ?? "gpt-4o-mini"
            
            NutritionAPIService.shared.configure(apiKey: apiKey, endpoint: endpoint, model: model)
            LLMAdviceService.shared.configure(apiKey: apiKey, endpoint: endpoint, model: model)
        }
    }
}

/// Root view that handles navigation between onboarding and main app
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        Group {
            if shouldShowOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shouldShowOnboarding)
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private var shouldShowOnboarding: Bool {
        if profiles.isEmpty {
            return true
        }
        return !(profiles.first?.hasCompletedOnboarding ?? false)
    }
    
    private func checkOnboardingStatus() {
        if let profile = profiles.first {
            hasCompletedOnboarding = profile.hasCompletedOnboarding
        }
    }
}
