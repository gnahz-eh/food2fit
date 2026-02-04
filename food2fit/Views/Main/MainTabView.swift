//
//  MainTabView.swift
//  food2fit
//
//  Main tab navigation for the app
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \Meal.timestamp, order: .reverse) private var meals: [Meal]
    
    @State private var selectedTab: Tab = .home
    @State private var showMealCapture: Bool = false
    
    var userProfile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home/Dashboard Tab
            DashboardView(userProfile: userProfile, meals: meals)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            // History Tab
            MealHistoryView(meals: meals)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(Tab.history)
            
            // Capture Tab (center button)
            Text("") // Placeholder, actual capture is modal
                .tabItem {
                    Label("Capture", systemImage: "camera.fill")
                }
                .tag(Tab.capture)
            
            // Stats Tab
            StatsView(meals: meals, userProfile: userProfile)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(Tab.stats)
            
            // Profile Tab
            ProfileView(profile: userProfile)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .capture {
                showMealCapture = true
                selectedTab = oldValue
            }
        }
        .fullScreenCover(isPresented: $showMealCapture) {
            MealCaptureView(userProfile: userProfile)
        }
    }
}

// MARK: - Tab Enum

enum Tab: Hashable {
    case home
    case history
    case capture
    case stats
    case profile
}

// MARK: - Preview

#Preview {
    MainTabView()
        .modelContainer(for: [UserProfile.self, Meal.self], inMemory: true)
}
