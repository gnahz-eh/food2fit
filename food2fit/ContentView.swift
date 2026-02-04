//
//  ContentView.swift
//  food2fit
//
//  Created by zhanghe on 2026/2/1.
//
//  This file is kept for compatibility but the main app flow
//  now uses RootView defined in food2fitApp.swift
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, Meal.self], inMemory: true)
}
