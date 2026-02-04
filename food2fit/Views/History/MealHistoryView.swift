//
//  MealHistoryView.swift
//  food2fit
//
//  Meal history list view
//

import SwiftUI
import SwiftData

struct MealHistoryView: View {
    let meals: [Meal]
    
    @State private var selectedFilter: MealType?
    @State private var searchText: String = ""
    
    var filteredMeals: [Meal] {
        var result = meals
        
        if let filter = selectedFilter {
            result = result.filter { $0.mealType == filter }
        }
        
        if !searchText.isEmpty {
            result = result.filter { meal in
                meal.foodItems.contains { food in
                    food.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        return result
    }
    
    var groupedMeals: [(date: Date, meals: [Meal])] {
        let grouped = Dictionary(grouping: filteredMeals) { meal in
            Calendar.current.startOfDay(for: meal.timestamp)
        }
        
        return grouped.map { (date: $0.key, meals: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                filterChips
                
                // Meal list
                if meals.isEmpty {
                    emptyState
                } else if filteredMeals.isEmpty {
                    noResultsState
                } else {
                    mealList
                }
            }
            .navigationTitle("History")
            .searchable(text: $searchText, prompt: "Search meals")
        }
    }
    
    // MARK: - Filter Chips
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                
                ForEach(MealType.allCases, id: \.self) { mealType in
                    FilterChip(
                        title: mealType.description,
                        icon: mealType.icon,
                        isSelected: selectedFilter == mealType
                    ) {
                        selectedFilter = mealType
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color.appSecondaryBackground)
    }
    
    // MARK: - Meal List
    
    private var mealList: some View {
        List {
            ForEach(groupedMeals, id: \.date) { group in
                Section {
                    ForEach(group.meals) { meal in
                        NavigationLink {
                            MealDetailView(meal: meal)
                        } label: {
                            MealHistoryRow(meal: meal)
                        }
                    }
                } header: {
                    Text(formatDate(group.date))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty States
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "fork.knife.circle",
            title: "No Meals Yet",
            message: "Start logging your meals to see your eating history and track your progress.",
            buttonTitle: nil,
            action: nil
        )
    }
    
    private var noResultsState: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No meals match your search or filter criteria.",
            buttonTitle: nil,
            action: nil
        )
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.appTertiaryBackground)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Meal History Row

struct MealHistoryRow: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let imageData = meal.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            } else {
                Image(systemName: meal.mealType.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 60, height: 60)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(meal.mealType.description)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formatTime(meal.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(meal.foodItems.map { $0.name }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(meal.totalCalories) kcal", systemImage: "flame")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("\(meal.foodItems.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    MealHistoryView(meals: [])
}
