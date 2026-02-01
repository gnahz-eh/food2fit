# food2fit - Implementation Guide

## Overview

food2fit is an iOS app that connects meals to exercise by calculating how much physical activity is needed to burn off the calories from a photographed meal.

## Architecture

### MVC Pattern with Service Layer

The app follows the Model-View-Controller pattern with separate service classes for business logic:

```
View Controllers:
├── WelcomeViewController       # Entry point
├── MealCameraViewController    # Photo capture
└── ExerciseResultsViewController # Results display

Services:
├── CalorieCalculationService   # Calorie estimation
└── ExerciseConversionService   # Exercise conversion logic
```

## User Flow

1. **Welcome Screen** (`WelcomeViewController`)
   - Shows app introduction
   - "Get Started" button launches camera modal

2. **Camera Screen** (`MealCameraViewController`)
   - Take photo or select from library
   - Automatically processes image on selection

3. **Results Screen** (`ExerciseResultsViewController`)
   - Shows meal photo
   - Lists 8 exercise options with time needed
   - "Done" button returns to welcome screen

## Key Components

### CalorieCalculationService

**Current Implementation**: Simulates calorie estimation with random values (100-700 cal range)

**Production Ready**: Designed for easy integration with:
- Core ML models for on-device food recognition
- Cloud APIs (Clarifai, Google Vision, AWS Rekognition)
- Custom trained models

```swift
// Future integration point
static func estimateCalories(from image: UIImage) -> Int {
    // Replace simulation with:
    // 1. Core ML model prediction
    // 2. Cloud API call
    // 3. Custom model inference
}
```

### ExerciseConversionService

**Exercise Database**: 8 activities with accurate calorie burn rates per minute
- Running: 11.4 cal/min
- Jogging: 7.0 cal/min
- Walking: 3.5 cal/min
- Cycling: 8.5 cal/min
- Swimming: 9.0 cal/min
- Jump Rope: 12.0 cal/min
- Dancing: 6.0 cal/min
- Yoga: 3.0 cal/min

**Features**:
- Calculates time needed for each exercise
- Formats results in human-readable format (hours + minutes)
- Extensible for adding more exercises

### ExerciseResultsViewController

**Custom UI Components**:
- `ExerciseCell`: Custom table view cell with exercise icon, name, and time
- Scrollable content for long exercise lists
- Full-screen presentation with dismissal

## Permissions

Required iOS permissions (configured in `Info.plist`):
- `NSCameraUsageDescription`: Camera access for meal photos
- `NSPhotoLibraryUsageDescription`: Photo library access for selecting existing photos

## Future Enhancements

### High Priority
1. **ML Integration**: Replace simulated calories with real food recognition
2. **User Profiles**: Save user weight for personalized calorie burn rates
3. **History**: Track meals and exercises over time

### Medium Priority
4. **HealthKit Integration**: Sync with Apple Health
5. **Nutritional Breakdown**: Show macros, not just calories
6. **Custom Exercises**: Let users add their own activities

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
