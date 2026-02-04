//
//  StatsView.swift
//  food2fit
//
//  Statistics and analytics view
//

import SwiftUI
import Charts

struct StatsView: View {
    let meals: [Meal]
    let userProfile: UserProfile?
    
    @State private var selectedTimeRange: TimeRange = .week
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time range picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Summary cards
                    summaryCardsSection
                    
                    // Calorie chart
                    calorieChartSection
                    
                    // Meal breakdown
                    mealBreakdownSection
                    
                    // Top foods
                    topFoodsSection
                    
                    // Exercise summary
                    exerciseSummarySection
                }
                .padding(.vertical)
            }
            .background(Color.appBackground)
            .navigationTitle("Statistics")
        }
    }
    
    // MARK: - Summary Cards
    
    private var summaryCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SummaryStatCard(
                title: "Avg. Daily Calories",
                value: "\(averageDailyCalories)",
                subtitle: "kcal",
                icon: "flame.fill",
                color: .orange
            )
            
            SummaryStatCard(
                title: "Total Meals",
                value: "\(filteredMeals.count)",
                subtitle: "meals logged",
                icon: "fork.knife",
                color: .green
            )
            
            SummaryStatCard(
                title: "Days Tracked",
                value: "\(uniqueDays)",
                subtitle: "days",
                icon: "calendar",
                color: .blue
            )
            
            SummaryStatCard(
                title: "Goal Progress",
                value: "\(goalProgressPercentage)%",
                subtitle: "on target",
                icon: "target",
                color: .purple
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Calorie Chart
    
    private var calorieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Calorie Intake", subtitle: "Daily breakdown")
                .padding(.horizontal)
            
            CardView {
                if #available(iOS 16.0, *) {
                    Chart(dailyCalorieData) { data in
                        BarMark(
                            x: .value("Day", data.date, unit: .day),
                            y: .value("Calories", data.calories)
                        )
                        .foregroundStyle(
                            data.calories > (userProfile?.dailyCalorieTarget ?? 2000)
                            ? Color.red.gradient
                            : Color.green.gradient
                        )
                        .cornerRadius(4)
                        
                        // Target line
                        RuleMark(y: .value("Target", userProfile?.dailyCalorieTarget ?? 2000))
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                } else {
                    // Fallback for iOS 15
                    Text("Charts require iOS 16+")
                        .foregroundColor(.secondary)
                        .frame(height: 200)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Meal Breakdown
    
    private var mealBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Meal Types", subtitle: "Distribution by meal")
                .padding(.horizontal)
            
            CardView {
                VStack(spacing: 12) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        let count = filteredMeals.filter { $0.mealType == mealType }.count
                        let percentage = filteredMeals.isEmpty ? 0 : Double(count) / Double(filteredMeals.count)
                        
                        HStack {
                            Image(systemName: mealType.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 24)
                            
                            Text(mealType.description)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("\(count)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(mealTypeColor(mealType))
                                    .frame(width: geometry.size.width * percentage)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Top Foods
    
    private var topFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Top Foods", subtitle: "Most logged items")
                .padding(.horizontal)
            
            CardView {
                if topFoods.isEmpty {
                    Text("No food data available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    VStack(spacing: 12) {
                        ForEach(Array(topFoods.prefix(5).enumerated()), id: \.element.name) { index, food in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(Color.accentColor))
                                
                                Text(food.name)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(food.count) times")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Exercise Summary
    
    private var exerciseSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Exercise Needed", subtitle: "To burn consumed calories")
                .padding(.horizontal)
            
            CardView {
                VStack(spacing: 16) {
                    let totalCalories = filteredMeals.reduce(0) { $0 + $1.totalCalories }
                    let weight = userProfile?.weightKg ?? 70
                    
                    ForEach([ExerciseType.running, .walking, .cycling, .swimming], id: \.self) { exercise in
                        let minutes = exercise.minutesToBurn(calories: totalCalories, weightKg: weight)
                        
                        HStack {
                            Image(systemName: exercise.icon)
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            Text(exercise.description)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text(formatMinutes(minutes))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredMeals: [Meal] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return meals.filter { $0.timestamp >= startDate }
    }
    
    private var dailyCalorieData: [DailyCalorieData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredMeals) { meal in
            calendar.startOfDay(for: meal.timestamp)
        }
        
        return grouped.map { date, meals in
            DailyCalorieData(
                date: date,
                dayName: "",
                calories: meals.reduce(0) { $0 + $1.totalCalories },
                target: userProfile?.dailyCalorieTarget ?? 2000
            )
        }.sorted { $0.date < $1.date }
    }
    
    private var averageDailyCalories: Int {
        guard !dailyCalorieData.isEmpty else { return 0 }
        let total = dailyCalorieData.reduce(0) { $0 + $1.calories }
        return total / dailyCalorieData.count
    }
    
    private var uniqueDays: Int {
        Set(filteredMeals.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
    }
    
    private var goalProgressPercentage: Int {
        guard let target = userProfile?.dailyCalorieTarget, target > 0 else { return 0 }
        let daysOnTarget = dailyCalorieData.filter { data in
            let difference = abs(data.calories - target)
            return difference <= Int(Double(target) * 0.15) // Within 15%
        }.count
        
        guard !dailyCalorieData.isEmpty else { return 0 }
        return Int((Double(daysOnTarget) / Double(dailyCalorieData.count)) * 100)
    }
    
    private var topFoods: [(name: String, count: Int)] {
        var foodCounts: [String: Int] = [:]
        
        for meal in filteredMeals {
            for food in meal.foodItems {
                foodCounts[food.name, default: 0] += 1
            }
        }
        
        return foodCounts.map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // MARK: - Helper Methods
    
    private func mealTypeColor(_ type: MealType) -> Color {
        switch type {
        case .breakfast: return .orange
        case .lunch: return .green
        case .dinner: return .blue
        case .snack: return .purple
        }
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes) min"
    }
}

// MARK: - Summary Stat Card

struct SummaryStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Spacer()
                }
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StatsView(meals: [], userProfile: nil)
}
