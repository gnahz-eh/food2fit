# food2fit - Implementation Guide

## Overview

food2fit is a comprehensive iOS app that connects meals to exercise by analyzing food photos and calculating how much physical activity is needed to burn off the calories. The app uses a hybrid architecture combining on-device processing with cloud LLM APIs for intelligent nutrition analysis.

## Architecture

### MVVM Pattern with Services Layer

The app follows the Model-View-ViewModel pattern with separate service classes for business logic:

```
Models/
├── UserProfile.swift       # User profile with fitness goals
├── Meal.swift              # Meal entries with food items
└── ExerciseType.swift      # Exercise types with MET values

ViewModels/
├── OnboardingViewModel.swift      # Onboarding flow logic
├── MealAnalysisViewModel.swift    # Meal photo analysis
├── DashboardViewModel.swift       # Home screen data
└── ProfileViewModel.swift         # Profile management

Services/
├── FoodRecognitionService.swift    # Vision/CoreML food recognition
├── NutritionAPIService.swift       # LLM-powered nutrition lookup
├── ExerciseConversionService.swift # Calorie to exercise conversion
└── LLMAdviceService.swift          # AI-powered fitness advice

Views/
├── Main/
│   └── MainTabView.swift          # Tab bar navigation
├── Onboarding/
│   └── OnboardingView.swift       # User onboarding flow
├── Dashboard/
│   └── DashboardView.swift        # Home screen
├── Camera/
│   ├── CameraView.swift           # Camera capture
│   ├── MealCaptureView.swift      # Meal photo flow
│   └── MealAnalysisResultsView.swift  # Analysis results
├── History/
│   ├── MealHistoryView.swift      # Meal history list
│   └── MealDetailView.swift       # Individual meal details
├── Stats/
│   └── StatsView.swift            # Statistics and charts
├── Profile/
│   └── ProfileView.swift          # User profile
└── Components/
    ├── AppColors.swift            # Color definitions
    └── CommonComponents.swift     # Reusable UI components
```

## Data Models

### UserProfile
- Stores user personal info (name, age, weight, height)
- Fitness goals (weight loss, muscle gain, maintenance)
- Activity level with BMR/TDEE calculations
- Persisted with SwiftData and iCloud sync

### Meal
- Meal type (breakfast, lunch, dinner, snack)
- Photo data
- Related food items with nutrition info
- Exercise suggestions
- LLM-generated advice

### ExerciseType
- 15+ exercise types with accurate MET values
- Calorie burn calculations based on user weight
- Intensity levels (low, moderate, high)

## Key Features

### 1. User Onboarding
- Step-by-step profile setup
- Collects: name, age, weight, height, sex
- Fitness goal selection
- Activity level assessment
- BMI/BMR/TDEE calculation

### 2. Meal Photo Capture
- Camera integration for new photos
- Photo library picker
- Meal type selection
- Preview before analysis

### 3. Food Recognition
- **Current**: Simulated recognition for MVP
- **Production**: CoreML model integration ready
- Supports multiple food items per photo
- Confidence scoring

### 4. Nutrition Analysis
- Local fallback database (30+ foods)
- LLM API integration (OpenAI/compatible)
- Full macronutrient breakdown
- Portion size estimation

### 5. Exercise Conversion
- MET-based calorie calculations
- Personalized to user weight
- 15 exercise types
- Duration formatting

### 6. Personalized Advice
- LLM-generated fitness advice
- Exercise suggestions
- Meal alternatives
- Health tips
- Motivational messages

### 7. Dashboard
- Daily calorie progress
- Quick stats overview
- Recent meals
- Weekly trend chart
- Streak tracking

### 8. Statistics
- Calorie intake charts (iOS 16+)
- Meal type breakdown
- Top foods list
- Exercise summary

## Technical Details

### Frameworks Used
- **SwiftUI**: UI framework
- **SwiftData**: Data persistence
- **PhotosUI**: Photo picker
- **AVFoundation**: Camera access
- **Charts**: Statistics visualization (iOS 16+)
- **Vision/CoreML**: Food recognition (production)

### API Integration
The app supports configurable LLM APIs:
- OpenAI GPT-4o-mini (default)
- Compatible with any OpenAI-compatible API
- Configurable in Profile > API Settings

### Calorie Calculations
Uses the Mifflin-St Jeor equation for BMR:
- Male: BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5
- Female: BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161

Exercise calorie burn uses MET values:
- kcal/min = (MET × 3.5 × weight_kg) / 200

### Permissions Required
- `NSCameraUsageDescription`: Camera for meal photos
- `NSPhotoLibraryUsageDescription`: Photo library access
- `NSPhotoLibraryAddUsageDescription`: Save photos

## Building the App

### Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9+

### Setup
1. Open `food2fit.xcodeproj` in Xcode
2. Select your development team for signing
3. Build and run on simulator or device

### Configuration
1. Navigate to Profile > API Settings
2. Enter your OpenAI API key
3. Optionally customize endpoint and model

## Future Enhancements

### High Priority
1. **Real CoreML Model**: Integrate Food101 or custom-trained model
2. **HealthKit Integration**: Sync with Apple Health
3. **Notifications**: Meal logging reminders
4. **Barcode Scanning**: Packaged food recognition

### Medium Priority
5. **Social Sharing**: Share progress achievements
6. **Watch App**: Quick meal logging from Apple Watch
7. **Widgets**: Home screen calorie widget
8. **Meal Planning**: Weekly meal suggestions

### Low Priority
9. **AR Visualization**: View exercise in AR
10. **Gamification**: Badges and achievements
11. **Community**: Compare with friends
12. **Recipe Integration**: Link to healthy recipes

### Low Priority
7. **Social Sharing**: Share results with friends
8. **Achievements**: Gamification for motivation
9. **Meal Database**: Build knowledge base of common meals

## Technical Details

**Language**: Swift 5+
**Minimum iOS**: iOS 13.0+
**UI Framework**: UIKit (programmatic Auto Layout)
**Dependencies**: None required (AppCenter optional)

## Development Setup

1. Clone repository
2. Open `sampleapp-ios-swift.xcworkspace` in Xcode
3. Optional: Run `pod install` if using AppCenter
4. Build and run on simulator or device

## Testing

**Unit Tests**: Add tests for service classes
```swift
// Example test structure
class CalorieCalculationServiceTests: XCTestCase {
    func testCalorieEstimationRange() {
        // Test that estimates are within reasonable range
    }
}
```

**UI Tests**: Add tests for navigation flow
```swift
class Food2FitUITests: XCTestCase {
    func testCompleteFlow() {
        // Test welcome -> camera -> results -> done
    }
}
```

## Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow Swift naming conventions
- Use Auto Layout for all UI elements
- Handle errors gracefully with user-friendly messages

## Security Considerations

- Never log sensitive user data
- Handle camera/library permission denials gracefully
- Validate image data before processing
- Use HTTPS for any future API calls
- Follow iOS security best practices

## Performance

**Current**:
- Instant calorie "calculation" (simulated)
- Smooth UI transitions
- Minimal memory footprint

**With ML Integration**:
- Consider on-device vs cloud tradeoffs
- Cache results when appropriate
- Show loading indicators for network calls
- Handle offline scenarios

## Contributing

When adding new features:
1. Follow existing code patterns
2. Update this documentation
3. Add appropriate comments
4. Test on multiple devices
5. Consider accessibility (VoiceOver, Dynamic Type)

## License

Copyright 2026 - All Rights Reserved
