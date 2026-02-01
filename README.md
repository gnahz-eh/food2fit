# food2fit - iOS App

**Connect Meals to Exercise**

food2fit is an iOS application that helps users understand the relationship between their meals and physical activity. Take a photo of your meal, and the app calculates how much exercise you need to burn off those calories.

## Features

- 📸 **Meal Photo Capture**: Take photos of your meals using the camera or select from your photo library
- 🔢 **Calorie Estimation**: Automatically estimates the caloric content of your meal (simulated for MVP)
- 🏃 **Exercise Conversion**: Converts calories into exercise time for various activities:
  - Running
  - Jogging
  - Walking
  - Cycling
  - Swimming
  - Jump Rope
  - Dancing
  - Yoga
- 💪 **Actionable Results**: See exactly how much time you need to spend on different exercises

## How It Works

1. **Capture**: Take a photo of your meal or select one from your library
2. **Calculate**: The app estimates the calories in your meal (currently simulated; production version would use ML models)
3. **Convert**: Calories are converted to exercise time for multiple activity types
4. **Act**: Choose your preferred exercise and get moving!

## About This App

This is a production iOS app designed to help users make informed decisions about their health by connecting what they eat with how they move. The app aims to provide motivation by showing the direct relationship between food intake and exercise output.

## Build the app

After forking the repository, you'll need to install CocoaPods to build the app.

```sh
sudo gem install cocoapods
```

Next, install the dependencies.

```sh
pod install
```

Open the .xcworkspace. The app can now build and run.

## Codesigning

_Codesigning is optional, but recommended._

Codesigning will allow you to deploy this app to your device.

When creating a new App ID for this app, be sure to check the **Camera** permission under the **App Services** section.

To sign the app in Xcode:

1. Open **.xcworkspace** from the app's folder.
2. Go to **General** within the .xcworkspace file.
3. Under **Identity**, edit the **Bundle Identifier** to match the app ID.
4. Import and select the provisioning profile under **Signing (Debug)** and **Signing (Release)**.

## Technical Details

- **Platform**: iOS
- **Language**: Swift
- **Architecture**: MVC pattern with service layer
- **Key Components**:
  - `WelcomeViewController`: Entry point and app introduction
  - `MealCameraViewController`: Handles photo capture and selection
  - `CalorieCalculationService`: Estimates calories from meal images
  - `ExerciseConversionService`: Converts calories to exercise time
  - `ExerciseResultsViewController`: Displays exercise options

## Future Enhancements

- Integration with Core ML for accurate food recognition
- Cloud-based food recognition API integration
- User profiles and history tracking
- Customizable exercise calorie burn rates based on user weight/fitness
- Social sharing features
- Integration with HealthKit
- Nutritional breakdown beyond calories
