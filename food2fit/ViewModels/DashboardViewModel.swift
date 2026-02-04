//
//  DashboardViewModel.swift
//  food2fit
//
//  ViewModel for the main dashboard
//

import Foundation
import SwiftUI
import SwiftData

/// View model for the dashboard/home screen
@MainActor
final class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var todaysMeals: [Meal] = []
    @Published var weeklyCalories: [DailyCalorieData] = []
    @Published var totalCaloriesToday: Int = 0
    @Published var exerciseTimeToday: Int = 0 // in minutes
    @Published var streakDays: Int = 0
    
    @Published var isLoading: Bool = false
    @Published var selectedTimeRange: TimeRange = .week
    
    // MARK: - Computed Properties
    
    var calorieProgress: Double {
        guard let target = userProfile?.dailyCalorieTarget, target > 0 else { return 0 }
        return min(Double(totalCaloriesToday) / Double(target), 1.0)
    }
    
    var caloriesRemaining: Int {
        guard let target = userProfile?.dailyCalorieTarget else { return 0 }
        return max(0, target - totalCaloriesToday)
    }
    
    // MARK: - Private Properties
    
    private var userProfile: UserProfile?
    
    // MARK: - Methods
    
    /// Load dashboard data
    func loadData(meals: [Meal], profile: UserProfile?) {
        userProfile = profile
        
        // Filter today's meals
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        todaysMeals = meals.filter { meal in
            calendar.isDate(meal.timestamp, inSameDayAs: today)
        }.sorted { $0.timestamp > $1.timestamp }
        
        // Calculate today's totals
        totalCaloriesToday = todaysMeals.reduce(0) { $0 + $1.totalCalories }
        
        // Calculate weekly data
        calculateWeeklyData(meals: meals)
        
        // Calculate streak
        calculateStreak(meals: meals)
    }
    
    /// Calculate weekly calorie data
    private func calculateWeeklyData(meals: [Meal]) {
        let calendar = Calendar.current
        var weekData: [DailyCalorieData] = []
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            
            let dayMeals = meals.filter { meal in
                calendar.isDate(meal.timestamp, inSameDayAs: date)
            }
            
            let calories = dayMeals.reduce(0) { $0 + $1.totalCalories }
            let dayName = dayOffset == 0 ? "Today" : dayFormatter.string(from: date)
            
            weekData.append(DailyCalorieData(
                date: date,
                dayName: dayName,
                calories: calories,
                target: userProfile?.dailyCalorieTarget ?? 2000
            ))
        }
        
        weeklyCalories = weekData
    }
    
    /// Calculate meal logging streak
    private func calculateStreak(meals: [Meal]) {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = Date()
        
        while true {
            let hasMealOnDate = meals.contains { meal in
                calendar.isDate(meal.timestamp, inSameDayAs: currentDate)
            }
            
            if hasMealOnDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        streakDays = streak
    }
    
    /// Get quick stats for display
    func getQuickStats() -> [QuickStat] {
        return [
            QuickStat(
                title: "Calories Today",
                value: "\(totalCaloriesToday)",
                unit: "kcal",
                icon: "flame",
                color: .orange
            ),
            QuickStat(
                title: "Meals Logged",
                value: "\(todaysMeals.count)",
                unit: "meals",
                icon: "fork.knife",
                color: .green
            ),
            QuickStat(
                title: "Streak",
                value: "\(streakDays)",
                unit: "days",
                icon: "star",
                color: .yellow
            ),
            QuickStat(
                title: "Remaining",
                value: "\(caloriesRemaining)",
                unit: "kcal",
                icon: "target",
                color: .blue
            )
        ]
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
}

// MARK: - Supporting Types

struct DailyCalorieData: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let calories: Int
    let target: Int
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(calories) / Double(target), 1.5) // Cap at 150%
    }
}

struct QuickStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
}

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}
