//
//  DashboardView.swift
//  food2fit
//
//  Main dashboard/home screen
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    let userProfile: UserProfile?
    let meals: [Meal]
    
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showMealCapture = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome header
                    welcomeHeader
                    
                    // Quick stats
                    quickStatsSection
                    
                    // Calorie progress
                    calorieProgressCard
                    
                    // Today's meals
                    todaysMealsSection
                    
                    // Weekly overview
                    weeklyOverviewSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showMealCapture = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .fullScreenCover(isPresented: $showMealCapture) {
                MealCaptureView(userProfile: userProfile)
            }
            .onAppear {
                viewModel.loadData(meals: meals, profile: userProfile)
            }
            .onChange(of: meals) { _, newMeals in
                viewModel.loadData(meals: newMeals, profile: userProfile)
            }
        }
    }
    
    // MARK: - Welcome Header
    
    private var welcomeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(userProfile?.name ?? "User")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Streak badge
            if viewModel.streakDays > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(viewModel.streakDays)")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(20)
            }
        }
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
    
    // MARK: - Quick Stats Section
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(viewModel.getQuickStats()) { stat in
                StatCard(
                    title: stat.title,
                    value: stat.value,
                    unit: stat.unit,
                    icon: stat.icon,
                    color: stat.color
                )
            }
        }
    }
    
    // MARK: - Calorie Progress Card
    
    private var calorieProgressCard: some View {
        CardView {
            VStack(spacing: 16) {
                HStack {
                    Text("Daily Calorie Goal")
                        .font(.headline)
                    Spacer()
                    Text("\(viewModel.totalCaloriesToday) / \(userProfile?.dailyCalorieTarget ?? 2000)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(progressColor)
                            .frame(width: geometry.size.width * viewModel.calorieProgress, height: 16)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.calorieProgress)
                    }
                }
                .frame(height: 16)
                
                HStack {
                    Label("\(viewModel.caloriesRemaining) kcal remaining", systemImage: "target")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.calorieProgress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
            }
        }
    }
    
    private var progressColor: Color {
        switch viewModel.calorieProgress {
        case ..<0.5: return .green
        case 0.5..<0.8: return .yellow
        case 0.8..<1.0: return .orange
        default: return .red
        }
    }
    
    // MARK: - Today's Meals Section
    
    private var todaysMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Today's Meals", subtitle: "\(viewModel.todaysMeals.count) meals logged")
            
            if viewModel.todaysMeals.isEmpty {
                emptyMealsCard
            } else {
                ForEach(viewModel.todaysMeals.prefix(3)) { meal in
                    MealRowCard(meal: meal)
                }
            }
        }
    }
    
    private var emptyMealsCard: some View {
        CardView {
            VStack(spacing: 12) {
                Image(systemName: "fork.knife.circle")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("No meals logged today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button {
                    showMealCapture = true
                } label: {
                    Text("Log Your First Meal")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Weekly Overview Section
    
    private var weeklyOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "This Week", subtitle: "Calorie intake overview")
            
            CardView {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(viewModel.weeklyCalories) { dayData in
                        VStack(spacing: 4) {
                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(dayData.date.isToday ? Color.accentColor : Color.gray.opacity(0.3))
                                .frame(width: 30, height: max(20, CGFloat(dayData.progress) * 80))
                            
                            // Day label
                            Text(dayData.dayName)
                                .font(.caption2)
                                .foregroundColor(dayData.date.isToday ? .primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 120)
            }
        }
    }
}

// MARK: - Meal Row Card

struct MealRowCard: View {
    let meal: Meal
    
    var body: some View {
        CardView(padding: 12) {
            HStack(spacing: 12) {
                // Meal image or icon
                if let imageData = meal.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                } else {
                    Image(systemName: meal.mealType.icon)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .frame(width: 50, height: 50)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.mealType.description)
                        .font(.headline)
                    
                    Text(meal.foodItems.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(meal.totalCalories)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text("kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Date Extension

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

// MARK: - Preview

#Preview {
    DashboardView(userProfile: nil, meals: [])
        .modelContainer(for: [UserProfile.self, Meal.self], inMemory: true)
}
