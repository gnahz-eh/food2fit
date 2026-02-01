You are an expert of IOS development and Swift programming language. You have extensive experience in building iOS applications using Swift and SwiftUI frameworks. You are knowledgeable about best practices, design patterns, and the latest trends in iOS development. You can provide guidance on various topics including UI design, data management, networking, and performance optimization in iOS apps.

I am trying to build an iOS application using Swift and SwiftUI. I need your help with coding, debugging, and optimizing my app. This is a real productive application, not a toy or demo app. It's name is "food2fit". Below is the description of the app.

## Main Functionalities
1. User could upload their meal photos, and the app will analyze the photos to estimate nutritional information such as calories, macronutrients, and portion sizes.
2. Instead of showing those abstract nutritional data, the app will translate them into practical fitness advice, such as jogging time required to burn the calories, suggested workouts, and meal planning tips. For example, if a user uploads a photo of a burger, the app might suggest a 30-minute jog to burn off the calories and recommend healthier meal options for future meals.
3. The main idea for this app is making the abstract nutritional information to real-world actions that users can take to improve their fitness and health. Most of people do not have a concrete understanding of calories and other data, and some basic exercise volume is easier to understand。

## Core Features
1. User could sign up and log in to their account. In the first time use the app, user need to provide some basic information such as age, weight, height, fitness goals (e.g., weight loss, muscle gain, maintenance), and activity level.
2. User could upload meal photos from their photo library or take new photos using the device camera.
3. The app will use image recognition and machine learning to analyze the meal photos and get the food items and quantities in the photos. We may leverage IOS CoreML and Vision framework for this purpose.
4. The app will estimate the nutritional information based on the recognized food items and quantities. We may use a third-party nutrition database API for this purpose.
5. The app will translate the nutritional information into practical fitness advice based on the user's profile and fitness goals. This may leverage LLM (Large Language Model) API to generate personalized advice.
6. User could view their meal history, nutritional summaries, and fitness advice in a user-friendly dashboard.
7. User could set reminders for meal logging and fitness activities.
8. User data should be securely stored and managed, possibly using iCloud.
9. User could share their progress and achievements on social media platforms.

## Core Technologies
The following table sorts out the core technologies, data and the possibility of implementing this idea on the device side.

| Function Module | Core Technology/Framework | Required Data/Model | Device-only? |
|:---|:---|:---|:---|
| 🍽️ Food recognition | Vision framework + Core ML | Pre-trained food image classification model (e.g., Food101) | Yes. Model can be bundled and run offline. |
| 📊 Calorie estimation | Local food database | Built-in food nutrition database (self prepared) | Hybrid. Identify food then query the local database for calories or call our server API. |
| 🏃‍♂️ Exercise conversion | LLM calculation and suggestion | Exercise heat consumption formula (e.g., MET) and LLM call | Hybrid. Compute baseline locally; use LLM for personalized suggestions. |

## Implementation scheme and data source
To realize this application, the key is to solve the problems of food recognition model and nutrition database.

### Food recognition model: We need a food recognition model that can be integrated into the App.
**Access method**: You can use Apple's **Create ML** tool to train a model with your own dataset; Or use **Core ML Tools** to convert the trained models on third-party platforms (such as PyTorch) to Core ML format. For example, an open source **Food101 CoreML** project provides a Core ML model that can identify 101 food categories, which is very suitable as a starting point.

### Nutrition database and exercise formula:
**Nutrition database**: This is the most challenging part of the implementation process. You need to build or find an open source, freely distributable food nutrition database by yourself and build it into the App. Existing applications in the market (such as Yazio and diet scanning AI) have huge databases, from which you can understand the necessity and complexity of databases.

**Exercise conversion**: the conversion of exercise amount can be performed according to the formula of **Metabolic equivalent (MET)**. This is a scientific and general computing method, which is very suitable for local computing. The formula is: **kcal consumed ≈ MET value × body weight (kg) × exercise time (hours)**. You can define the MET value of different sports (such as running and swimming) in advance, and then deduce how long you need to exercise according to the food calories.

#### Caution:

Hybrid architecture (recommended)
This plan combines offline capability with cloud intelligence.

**Core idea**: Do food identification on-device, send only the identified food name to a cloud LLM (OpenAI GPT-4o, Anthropic Claude, Google Gemini, etc.) for nutrition info, then complete exercise conversion on-device.

**Workflow**
1. User takes a photo; on-device Vision identifies it as "an apple".
2. Build a concise prompt, e.g.:
	> You are a professional nutritionist. Please only return data in JSON format without any other text. Estimate the approximate calories (kcal) of the following foods. The food is "apple". Assume a common medium size (~150g).
3. The app calls the LLM API with the prompt.
4. The LLM API returns structured data, e.g. `{ "food": "apple", "calories": 80 }`.
5. The app combines the returned calories with the user's weight on-device to calculate exercise time.

**Why this is better**
- **Solves the database problem**: No need to build and maintain a huge nutrition DB; the LLM supplies broad nutrition knowledge.
- **Flexible and intelligent**: Handles complex, mixed-dish descriptions (e.g., "a bowl of Lanzhou ramen with beef, egg, and vegetables") and provides reasonable estimates.
- **Keeps core logic offline**: Sensitive data (photos, weight) and final exercise conversion stay on-device; only non-identifying food names leave the device.
- **Controllable cost**: Pay-per-use LLM APIs can have lower upfront cost than building databases and maintaining servers.

## Development advantages and precautions
Choosing to run entirely on the device side will bring some unique advantages to your application, but you also need to pay attention to the corresponding challenges.

**Core advantages**
- **User privacy protection**: All photos and health data are processed on the user's device and will not be uploaded to any server, aligning with Apple's privacy requirements.
- **Offline availability**: Users can use all functions without network connectivity (e.g., underground gym, flight mode).
- **Rapid response**: No server round-trips, so recognition and calculation are fast and the experience stays smooth.

**Challenges and considerations**
- **Application volume**: Bundled ML models and a nutrition database may enlarge the app size. Balance model accuracy, database size, and UX.
- **Recognition accuracy**: On-device models—especially for complex cuisines or mixed dishes—may trail cloud services. Plan for continuous tuning and improvement.
- **Data updates**: Updating the food model or nutrition database requires an app update, which is less flexible than cloud-side updates.

To make the application more attractive and practical, consider these optimizations:
- **Personalization**: Let users input age, weight, height, and other info so calorie and exercise estimates are more accurate.
- **Diversified sports**: Offer conversions for multiple activities (walking, swimming, cycling) to match user preferences beyond running.
- **Interactive design**: Use an intuitive progress bar or animation to illustrate "it takes 20 minutes of running to burn this cake" so the concept is instantly clear.

So help me to build this "food2fit" iOS application using Swift and SwiftUI. Impmement the functionalities step by step, and make sure the code is clean, efficient, and follows best practices.