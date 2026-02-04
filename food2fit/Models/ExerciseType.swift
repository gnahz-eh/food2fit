//
//  ExerciseType.swift
//  food2fit
//
//  Exercise types with MET values for calorie calculation
//

import Foundation

/// Represents different types of exercises with their MET values
/// MET (Metabolic Equivalent of Task) is used to estimate calorie burn
enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case running = "Running"
    case jogging = "Jogging"
    case walking = "Walking"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case jumpRope = "Jump Rope"
    case dancing = "Dancing"
    case yoga = "Yoga"
    case hiking = "Hiking"
    case weightLifting = "Weight Lifting"
    case basketball = "Basketball"
    case tennis = "Tennis"
    case soccer = "Soccer"
    case rowing = "Rowing"
    case stairClimbing = "Stair Climbing"
    
    var id: String { rawValue }
    
    /// MET value for the exercise
    /// Reference: Compendium of Physical Activities
    var metValue: Double {
        switch self {
        case .running: return 9.8        // Running 6 mph (10 min/mile)
        case .jogging: return 7.0        // Jogging general
        case .walking: return 3.5        // Walking 3.5 mph
        case .cycling: return 7.5        // Cycling 12-14 mph
        case .swimming: return 8.0       // Swimming laps freestyle moderate
        case .jumpRope: return 12.3      // Jump rope moderate
        case .dancing: return 5.5        // Dancing general
        case .yoga: return 3.0           // Yoga hatha
        case .hiking: return 6.0         // Hiking cross country
        case .weightLifting: return 5.0  // Weight lifting general
        case .basketball: return 6.5     // Basketball game
        case .tennis: return 7.3         // Tennis singles
        case .soccer: return 7.0         // Soccer casual
        case .rowing: return 7.0         // Rowing stationary moderate
        case .stairClimbing: return 8.0  // Stair climbing machine
        }
    }
    
    /// Calories burned per minute per kg of body weight
    /// Formula: (MET × 3.5 × body weight in kg) / 200 = kcal/min
    func caloriesPerMinute(weightKg: Double) -> Double {
        return (metValue * 3.5 * weightKg) / 200
    }
    
    /// Calculate minutes needed to burn given calories
    func minutesToBurn(calories: Int, weightKg: Double) -> Int {
        let calPerMin = caloriesPerMinute(weightKg: weightKg)
        guard calPerMin > 0 else { return 0 }
        return Int(ceil(Double(calories) / calPerMin))
    }
    
    /// SF Symbol icon name for the exercise
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .jogging: return "figure.walk"
        case .walking: return "figure.walk.motion"
        case .cycling: return "bicycle"
        case .swimming: return "figure.pool.swim"
        case .jumpRope: return "figure.jumprope"
        case .dancing: return "figure.dance"
        case .yoga: return "figure.yoga"
        case .hiking: return "figure.hiking"
        case .weightLifting: return "dumbbell"
        case .basketball: return "basketball"
        case .tennis: return "tennis.racket"
        case .soccer: return "soccerball"
        case .rowing: return "oar.2.crossed"
        case .stairClimbing: return "stairs"
        }
    }
    
    /// Exercise intensity level
    var intensity: ExerciseIntensity {
        switch self {
        case .running, .jumpRope, .swimming, .stairClimbing:
            return .high
        case .jogging, .cycling, .basketball, .tennis, .soccer, .rowing, .hiking:
            return .moderate
        case .walking, .dancing, .yoga, .weightLifting:
            return .low
        }
    }
    
    /// Description of the exercise
    var description: String { rawValue }
    
    /// Detailed description including intensity
    var detailedDescription: String {
        "\(rawValue) (\(intensity.rawValue) intensity)"
    }
}

/// Exercise intensity levels
enum ExerciseIntensity: String, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .moderate: return "orange"
        case .high: return "red"
        }
    }
}
