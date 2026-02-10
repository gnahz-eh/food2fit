//
//  NutritionAPIService.swift
//  food2fit
//
//  Service for fetching nutrition information using LLM API
//

import Foundation

/// Nutrition information for a food item
struct NutritionInfo: Codable, Equatable {
    let food: String
    let calories: Int
    let protein: Double?
    let carbohydrates: Double?
    let fat: Double?
    let fiber: Double?
    let sugar: Double?
    let portionSize: String?
    let healthTips: String?
    
    init(
        food: String,
        calories: Int,
        protein: Double? = nil,
        carbohydrates: Double? = nil,
        fat: Double? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        portionSize: String? = nil,
        healthTips: String? = nil
    ) {
        self.food = food
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.portionSize = portionSize
        self.healthTips = healthTips
    }
}

/// LLM API response structure
struct LLMNutritionResponse: Codable {
    let food: String
    let calories: Int
    let protein: Double?
    let carbohydrates: Double?
    let fat: Double?
    let fiber: Double?
    let sugar: Double?
    let portionSize: String?
    let healthTips: String?
}

/// Errors for nutrition API service
enum NutritionAPIError: Error, LocalizedError {
    case invalidAPIKey
    case networkError(String)
    case parsingError(String)
    case rateLimitExceeded
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key. Please check your configuration."
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Failed to parse response: \(message)"
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error with code: \(code)"
        }
    }
}

/// Service for fetching nutrition information
/// Uses LLM API (OpenAI, Anthropic, etc.) for intelligent nutrition estimation
final class NutritionAPIService {
    
    static let shared = NutritionAPIService()
    
    private let cache = NutritionCache()
    
    /// API configuration
    private var apiKey: String?
    private var apiEndpoint: String = "https://api.openai.com/v1/chat/completions"
    private var modelName: String = "gpt-4o-mini"
    
    /// Local fallback nutrition database for offline mode
    private let fallbackDatabase: [String: NutritionInfo] = [
        "apple": NutritionInfo(food: "Apple", calories: 95, protein: 0.5, carbohydrates: 25, fat: 0.3, fiber: 4.4, sugar: 19, portionSize: "1 medium (182g)"),
        "banana": NutritionInfo(food: "Banana", calories: 105, protein: 1.3, carbohydrates: 27, fat: 0.4, fiber: 3.1, sugar: 14, portionSize: "1 medium (118g)"),
        "orange": NutritionInfo(food: "Orange", calories: 62, protein: 1.2, carbohydrates: 15, fat: 0.2, fiber: 3.1, sugar: 12, portionSize: "1 medium (131g)"),
        "hamburger": NutritionInfo(food: "Hamburger", calories: 540, protein: 25, carbohydrates: 40, fat: 29, fiber: 2, sugar: 8, portionSize: "1 burger with bun"),
        "pizza": NutritionInfo(food: "Pizza", calories: 285, protein: 12, carbohydrates: 36, fat: 10, fiber: 2.5, sugar: 4, portionSize: "1 slice (107g)"),
        "salad": NutritionInfo(food: "Salad", calories: 150, protein: 3, carbohydrates: 12, fat: 10, fiber: 3, sugar: 5, portionSize: "1 bowl (200g)"),
        "sandwich": NutritionInfo(food: "Sandwich", calories: 350, protein: 15, carbohydrates: 40, fat: 14, fiber: 3, sugar: 5, portionSize: "1 sandwich"),
        "pasta": NutritionInfo(food: "Pasta", calories: 420, protein: 15, carbohydrates: 75, fat: 8, fiber: 4, sugar: 4, portionSize: "1 plate (250g)"),
        "rice bowl": NutritionInfo(food: "Rice Bowl", calories: 380, protein: 12, carbohydrates: 65, fat: 8, fiber: 2, sugar: 3, portionSize: "1 bowl (300g)"),
        "sushi": NutritionInfo(food: "Sushi", calories: 350, protein: 15, carbohydrates: 50, fat: 8, fiber: 2, sugar: 6, portionSize: "8 pieces"),
        "steak": NutritionInfo(food: "Steak", calories: 450, protein: 45, carbohydrates: 0, fat: 28, fiber: 0, sugar: 0, portionSize: "6 oz (170g)"),
        "chicken breast": NutritionInfo(food: "Chicken Breast", calories: 165, protein: 31, carbohydrates: 0, fat: 3.6, fiber: 0, sugar: 0, portionSize: "3.5 oz (100g)"),
        "salmon": NutritionInfo(food: "Salmon", calories: 280, protein: 30, carbohydrates: 0, fat: 17, fiber: 0, sugar: 0, portionSize: "4 oz (113g)"),
        "french fries": NutritionInfo(food: "French Fries", calories: 365, protein: 4, carbohydrates: 48, fat: 17, fiber: 4, sugar: 0.3, portionSize: "medium serving (117g)"),
        "ice cream": NutritionInfo(food: "Ice Cream", calories: 270, protein: 5, carbohydrates: 32, fat: 14, fiber: 1, sugar: 28, portionSize: "1 cup (132g)"),
        "cake": NutritionInfo(food: "Cake", calories: 350, protein: 4, carbohydrates: 52, fat: 14, fiber: 1, sugar: 36, portionSize: "1 slice (100g)"),
        "cookie": NutritionInfo(food: "Cookie", calories: 150, protein: 2, carbohydrates: 20, fat: 7, fiber: 0.5, sugar: 12, portionSize: "1 large cookie (30g)"),
        "bread": NutritionInfo(food: "Bread", calories: 80, protein: 3, carbohydrates: 15, fat: 1, fiber: 1, sugar: 1.5, portionSize: "1 slice (30g)"),
        "eggs": NutritionInfo(food: "Eggs", calories: 155, protein: 13, carbohydrates: 1.1, fat: 11, fiber: 0, sugar: 1.1, portionSize: "2 large eggs"),
        "pancakes": NutritionInfo(food: "Pancakes", calories: 350, protein: 8, carbohydrates: 58, fat: 10, fiber: 2, sugar: 14, portionSize: "3 pancakes with syrup"),
        "cereal": NutritionInfo(food: "Cereal", calories: 200, protein: 5, carbohydrates: 40, fat: 2, fiber: 3, sugar: 12, portionSize: "1 bowl with milk"),
        "yogurt": NutritionInfo(food: "Yogurt", calories: 150, protein: 12, carbohydrates: 20, fat: 4, fiber: 0, sugar: 18, portionSize: "1 cup (245g)"),
        "smoothie": NutritionInfo(food: "Smoothie", calories: 250, protein: 6, carbohydrates: 45, fat: 5, fiber: 4, sugar: 35, portionSize: "16 oz (473ml)"),
        "coffee": NutritionInfo(food: "Coffee", calories: 5, protein: 0.3, carbohydrates: 0, fat: 0, fiber: 0, sugar: 0, portionSize: "1 cup black (240ml)"),
        "burrito": NutritionInfo(food: "Burrito", calories: 600, protein: 25, carbohydrates: 70, fat: 24, fiber: 8, sugar: 4, portionSize: "1 burrito"),
        "taco": NutritionInfo(food: "Taco", calories: 210, protein: 10, carbohydrates: 20, fat: 10, fiber: 2, sugar: 2, portionSize: "1 taco"),
        "soup": NutritionInfo(food: "Soup", calories: 180, protein: 8, carbohydrates: 22, fat: 6, fiber: 3, sugar: 4, portionSize: "1 bowl (240ml)"),
        "noodles": NutritionInfo(food: "Noodles", calories: 380, protein: 12, carbohydrates: 68, fat: 8, fiber: 3, sugar: 2, portionSize: "1 bowl"),
        "fried rice": NutritionInfo(food: "Fried Rice", calories: 450, protein: 10, carbohydrates: 55, fat: 20, fiber: 2, sugar: 3, portionSize: "1 plate (300g)"),
        "dumplings": NutritionInfo(food: "Dumplings", calories: 280, protein: 12, carbohydrates: 35, fat: 10, fiber: 2, sugar: 2, portionSize: "6 dumplings")
    ]
    
    private init() {}
    
    /// Configure the API service
    /// - Parameters:
    ///   - apiKey: API key for the LLM service
    ///   - endpoint: API endpoint URL
    ///   - model: Model name to use
    func configure(apiKey: String, endpoint: String? = nil, model: String? = nil) {
        self.apiKey = apiKey
        if let endpoint = endpoint {
            self.apiEndpoint = endpoint
        }
        if let model = model {
            self.modelName = model
        }
    }
    
    /// Fetch nutrition information for a food item
    /// - Parameter foodName: Name of the food item
    /// - Returns: NutritionInfo for the food
    func fetchNutrition(for foodName: String) async throws -> NutritionInfo {
        let normalizedName = foodName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let cached = await cache.cachedNutrition(for: normalizedName) {
            return cached
        }
        
        if let localNutrition = fallbackDatabase[normalizedName.lowercased()] {
            try await Task.sleep(nanoseconds: 500_000_000)
            await cache.store(localNutrition, for: normalizedName)
            return localNutrition
        }
        
        if let apiKey = apiKey, !apiKey.isEmpty {
            let info = try await fetchFromLLM(foodName: normalizedName, apiKey: apiKey)
            await cache.store(info, for: normalizedName)
            return info
        }
        
        let estimate = generateEstimatedNutrition(for: normalizedName)
        await cache.store(estimate, for: normalizedName)
        return estimate
    }
    
    /// Fetch nutrition information from LLM API
    private func fetchFromLLM(foodName: String, apiKey: String) async throws -> NutritionInfo {
        let prompt = """
        You are a professional nutritionist. Please estimate the nutritional information for the following food item.
        Return ONLY valid JSON without any markdown formatting, code blocks, or additional text.
        
        Food: "\(foodName)"
        Assume a common, typical serving size.
        
        Return JSON with this exact structure:
        {
            "food": "food name",
            "calories": number,
            "protein": number (grams),
            "carbohydrates": number (grams),
            "fat": number (grams),
            "fiber": number (grams),
            "sugar": number (grams),
            "portionSize": "description of portion",
            "healthTips": "brief health tip"
        }
        """
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": "You are a nutritionist that returns only JSON data."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: apiEndpoint) else {
            throw NutritionAPIError.networkError("Invalid API endpoint")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NutritionAPIError.networkError("Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw NutritionAPIError.rateLimitExceeded
            }
            throw NutritionAPIError.serverError(httpResponse.statusCode)
        }
        
        // Parse OpenAI response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NutritionAPIError.parsingError("Could not parse API response structure")
        }
        
        // Parse the nutrition JSON from the content
        guard let nutritionData = content.data(using: .utf8) else {
            throw NutritionAPIError.parsingError("Could not convert content to data")
        }
        
        let nutritionResponse = try JSONDecoder().decode(LLMNutritionResponse.self, from: nutritionData)
        
        return NutritionInfo(
            food: nutritionResponse.food,
            calories: nutritionResponse.calories,
            protein: nutritionResponse.protein,
            carbohydrates: nutritionResponse.carbohydrates,
            fat: nutritionResponse.fat,
            fiber: nutritionResponse.fiber,
            sugar: nutritionResponse.sugar,
            portionSize: nutritionResponse.portionSize,
            healthTips: nutritionResponse.healthTips
        )
    }
    
    /// Generate estimated nutrition when offline or API unavailable
    private func generateEstimatedNutrition(for foodName: String) -> NutritionInfo {
        // Simple heuristic-based estimation
        let name = foodName.lowercased()
        var calories = 200 // Default
        var protein: Double = 5
        var carbs: Double = 25
        var fat: Double = 8
        
        // Adjust based on keywords
        if name.contains("fried") || name.contains("crispy") {
            calories += 150
            fat += 12
        }
        if name.contains("grilled") || name.contains("baked") {
            calories -= 50
            fat -= 5
        }
        if name.contains("meat") || name.contains("chicken") || name.contains("beef") || name.contains("pork") {
            calories = 300
            protein = 30
            carbs = 0
            fat = 15
        }
        if name.contains("vegetable") || name.contains("salad") {
            calories = 100
            protein = 3
            carbs = 12
            fat = 5
        }
        if name.contains("dessert") || name.contains("cake") || name.contains("ice cream") {
            calories = 350
            carbs = 45
            fat = 15
        }
        if name.contains("rice") || name.contains("pasta") || name.contains("noodle") {
            calories = 400
            carbs = 65
            protein = 10
        }
        
        return NutritionInfo(
            food: foodName.capitalized,
            calories: calories,
            protein: protein,
            carbohydrates: carbs,
            fat: fat,
            portionSize: "1 serving (estimated)"
        )
    }
}
