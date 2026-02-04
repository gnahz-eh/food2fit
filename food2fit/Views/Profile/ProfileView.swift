//
//  ProfileView.swift
//  food2fit
//
//  User profile view
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    let profile: UserProfile?
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ProfileViewModel()
    
    @State private var showDeleteConfirmation = false
    @State private var showAPISettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader
                    
                    // Stats cards
                    statsCardsSection
                    
                    // Profile details
                    profileDetailsSection
                    
                    // Settings section
                    settingsSection
                    
                    // App info
                    appInfoSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditing ? "Done" : "Edit") {
                        if viewModel.isEditing {
                            viewModel.saveProfile(context: modelContext)
                        } else {
                            viewModel.isEditing = true
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadProfile(profile)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $showAPISettings) {
                APISettingsView()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient.appGradient)
                    .frame(width: 100, height: 100)
                
                Text(initials)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            if viewModel.isEditing {
                TextField("Name", text: $viewModel.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 200)
            } else {
                Text(viewModel.name.isEmpty ? "User" : viewModel.name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            // Goal badge
            HStack {
                Image(systemName: (profile?.fitnessGoal ?? .generalHealth).icon)
                Text((profile?.fitnessGoal ?? .generalHealth).description)
            }
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.goalColor(for: profile?.fitnessGoal ?? .generalHealth).opacity(0.15))
            .foregroundColor(Color.goalColor(for: profile?.fitnessGoal ?? .generalHealth))
            .cornerRadius(20)
        }
    }
    
    private var initials: String {
        let name = viewModel.name
        let components = name.split(separator: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return (firstInitial + lastInitial).uppercased()
    }
    
    // MARK: - Stats Cards
    
    private var statsCardsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(viewModel.getProfileStats()) { stat in
                ProfileStatCard(stat: stat)
            }
        }
    }
    
    // MARK: - Profile Details
    
    private var profileDetailsSection: some View {
        CardView {
            VStack(spacing: 16) {
                if viewModel.isEditing {
                    editableDetails
                } else {
                    readOnlyDetails
                }
            }
        }
    }
    
    private var readOnlyDetails: some View {
        VStack(spacing: 12) {
            ProfileDetailRow(label: "Age", value: viewModel.age, icon: "calendar")
            Divider()
            ProfileDetailRow(label: "Weight", value: "\(viewModel.weightKg) kg", icon: "scalemass")
            Divider()
            ProfileDetailRow(label: "Height", value: "\(viewModel.heightCm) cm", icon: "ruler")
            Divider()
            ProfileDetailRow(label: "Sex", value: viewModel.biologicalSex.description, icon: "person")
            Divider()
            ProfileDetailRow(label: "Activity", value: viewModel.activityLevel.description, icon: "figure.walk")
        }
    }
    
    private var editableDetails: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Age")
                    .foregroundColor(.secondary)
                Spacer()
                TextField("Age", text: $viewModel.age)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            
            Divider()
            
            HStack {
                Text("Weight (kg)")
                    .foregroundColor(.secondary)
                Spacer()
                TextField("Weight", text: $viewModel.weightKg)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            
            Divider()
            
            HStack {
                Text("Height (cm)")
                    .foregroundColor(.secondary)
                Spacer()
                TextField("Height", text: $viewModel.heightCm)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            
            Divider()
            
            Picker("Biological Sex", selection: $viewModel.biologicalSex) {
                ForEach(BiologicalSex.allCases, id: \.self) { sex in
                    Text(sex.description).tag(sex)
                }
            }
            
            Divider()
            
            Picker("Fitness Goal", selection: $viewModel.fitnessGoal) {
                ForEach(FitnessGoal.allCases, id: \.self) { goal in
                    Text(goal.description).tag(goal)
                }
            }
            
            Divider()
            
            Picker("Activity Level", selection: $viewModel.activityLevel) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Text(level.description).tag(level)
                }
            }
        }
    }
    
    // MARK: - Settings Section
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
            
            CardView(padding: 0) {
                VStack(spacing: 0) {
                    SettingsRow(icon: "key", title: "API Configuration", color: .blue) {
                        showAPISettings = true
                    }
                    
                    Divider().padding(.leading, 52)
                    
                    SettingsRow(icon: "bell", title: "Notifications", color: .orange) {
                        // Navigate to notifications settings
                    }
                    
                    Divider().padding(.leading, 52)
                    
                    SettingsRow(icon: "icloud", title: "iCloud Sync", color: .cyan) {
                        // Navigate to sync settings
                    }
                    
                    Divider().padding(.leading, 52)
                    
                    SettingsRow(icon: "square.and.arrow.up", title: "Export Data", color: .green) {
                        // Export user data
                    }
                }
            }
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(spacing: 12) {
            Text("food2fit")
                .font(.headline)
            
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Transform meals into actionable fitness goals")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
}

// MARK: - Profile Stat Card

struct ProfileStatCard: View {
    let stat: ProfileStat
    
    var body: some View {
        CardView {
            VStack(spacing: 4) {
                Text(stat.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(stat.value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(stat.color)
                
                Text(stat.subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Profile Detail Row

struct ProfileDetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(color)
                    .cornerRadius(6)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// MARK: - API Settings View

struct APISettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("openai_api_key") private var apiKey: String = ""
    @AppStorage("api_endpoint") private var apiEndpoint: String = "https://api.openai.com/v1/chat/completions"
    @AppStorage("model_name") private var modelName: String = "gpt-4o-mini"
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("API Key", text: $apiKey)
                    TextField("API Endpoint", text: $apiEndpoint)
                        .autocapitalization(.none)
                    TextField("Model Name", text: $modelName)
                        .autocapitalization(.none)
                } header: {
                    Text("LLM API Configuration")
                } footer: {
                    Text("Configure your OpenAI or compatible API for enhanced nutrition analysis and personalized advice.")
                }
                
                Section {
                    Button("Use Default Settings") {
                        apiEndpoint = "https://api.openai.com/v1/chat/completions"
                        modelName = "gpt-4o-mini"
                    }
                }
            }
            .navigationTitle("API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Apply settings to services
                        if !apiKey.isEmpty {
                            NutritionAPIService.shared.configure(
                                apiKey: apiKey,
                                endpoint: apiEndpoint,
                                model: modelName
                            )
                            LLMAdviceService.shared.configure(
                                apiKey: apiKey,
                                endpoint: apiEndpoint,
                                model: modelName
                            )
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView(profile: nil)
        .modelContainer(for: UserProfile.self, inMemory: true)
}
