# food2fit - iOS App

**Transform Meals into Actionable Fitness Goals**

food2fit is a comprehensive iOS application that helps users understand the relationship between their meals and physical activity. Take a photo of your meal, and the app analyzes the food, estimates calories, and shows you exactly how much exercise you need to burn it off.

## ✨ Features

### Core Functionality
- 📸 **Meal Photo Capture**: Take photos of your meals or select from your photo library
- 🍎 **AI Food Recognition**: Automatically identifies food items in your photos
- 🔢 **Nutrition Analysis**: Estimates calories, protein, carbs, fat, and more
- 🏃 **Exercise Conversion**: Converts calories into time for 15+ activities
- 💡 **Personalized Advice**: AI-powered suggestions based on your goals

### User Experience
- 👤 **User Profiles**: Personalized calorie targets based on your stats
- 📊 **Dashboard**: Daily progress, streaks, and weekly trends
- 📈 **Statistics**: Charts and analytics for your eating habits
- 📋 **Meal History**: Browse and review past meals
- ⚙️ **Customizable**: Configure API settings for enhanced analysis

## 🎯 Supported Exercises

| Exercise | Intensity | MET Value |
|----------|-----------|-----------|
| Running | High | 9.8 |
| Jump Rope | High | 12.3 |
| Swimming | High | 8.0 |
| Stair Climbing | High | 8.0 |
| Cycling | Moderate | 7.5 |
| Jogging | Moderate | 7.0 |
| Tennis | Moderate | 7.3 |
| Hiking | Moderate | 6.0 |
| Walking | Low | 3.5 |
| Dancing | Low | 5.5 |
| Yoga | Low | 3.0 |
| Weight Lifting | Low | 5.0 |

## 🛠 Technical Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData with iCloud sync
- **Architecture**: MVVM with Services layer
- **Charts**: Swift Charts (iOS 16+)
- **AI Integration**: OpenAI API compatible

## 📱 Requirements

- iOS 17.0+
- Xcode 15.0+
- Camera permission for meal photos
- Photo library permission for selecting images
- Optional: OpenAI API key for enhanced analysis

## 🚀 Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/gnahz-eh/food2fit2.git
cd food2fit2
```

2. Open the project in Xcode:
```bash
open food2fit.xcodeproj
```

3. Select your development team for code signing

4. Build and run on a simulator or device

### Configuration

For enhanced AI-powered nutrition analysis:

1. Launch the app and complete onboarding
2. Go to **Profile** tab
3. Tap **API Configuration**
4. Enter your OpenAI API key
5. (Optional) Customize endpoint for compatible APIs

## 📖 How It Works

### The Science Behind It

**Calorie Calculations**: Uses the Mifflin-St Jeor equation
```
BMR (male) = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) + 5
BMR (female) = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) - 161
TDEE = BMR × Activity Multiplier
```

**Exercise Conversion**: Uses Metabolic Equivalent of Task (MET)
```
Calories/minute = (MET × 3.5 × weight_kg) / 200
```

### Workflow

1. **Capture**: Take or select a photo of your meal
2. **Recognize**: AI identifies food items in the photo
3. **Analyze**: Fetch nutrition data (local DB or LLM API)
4. **Convert**: Calculate exercise time based on your weight
5. **Advise**: Get personalized fitness recommendations

## 🗂 Project Structure

```
food2fit/
├── Models/
│   ├── UserProfile.swift      # User data model
│   ├── Meal.swift             # Meal entries
│   └── ExerciseType.swift     # Exercise definitions
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   ├── MealAnalysisViewModel.swift
│   ├── DashboardViewModel.swift
│   └── ProfileViewModel.swift
├── Services/
│   ├── FoodRecognitionService.swift
│   ├── NutritionAPIService.swift
│   ├── ExerciseConversionService.swift
│   └── LLMAdviceService.swift
├── Views/
│   ├── Main/               # Tab navigation
│   ├── Onboarding/         # First-time setup
│   ├── Dashboard/          # Home screen
│   ├── Camera/             # Meal capture
│   ├── History/            # Past meals
│   ├── Stats/              # Analytics
│   ├── Profile/            # User settings
│   └── Components/         # Reusable UI
└── food2fitApp.swift       # App entry point
```

## 🔮 Roadmap

### Coming Soon
- [ ] CoreML food recognition model integration
- [ ] HealthKit integration
- [ ] Apple Watch companion app
- [ ] Home screen widgets
- [ ] Push notification reminders

### Future Ideas
- [ ] Barcode scanning for packaged foods
- [ ] Social sharing features
- [ ] Meal planning suggestions
- [ ] AR exercise visualization
- [ ] Community challenges

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is available under the MIT License.

## 🙏 Acknowledgments

- MET values from the [Compendium of Physical Activities](https://sites.google.com/site/compendiumofphysicalactivities/)
- Mifflin-St Jeor equation for BMR calculations
- Apple for SwiftUI and SwiftData frameworks
