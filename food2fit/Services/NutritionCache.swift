//
//  NutritionCache.swift
//  food2fit
//
//  Lightweight persistence layer for caching nutrition lookups
//

import Foundation

/// Thread-safe cache for NutritionInfo responses with automatic expiration
actor NutritionCache {
    private struct CachedEntry: Codable {
        let info: NutritionInfo
        let timestamp: Date
    }
    
    private var storage: [String: CachedEntry]
    private let storageKey = "nutrition_cache_v1"
    private let entryLifetime: TimeInterval = 7 * 24 * 60 * 60 // one week
    
    init(userDefaults: UserDefaults = .standard) {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: CachedEntry].self, from: data) {
            storage = decoded
        } else {
            storage = [:]
        }
        self.userDefaults = userDefaults
    }
    
    /// Retrieve cached nutrition info if it is still fresh
    func cachedNutrition(for foodName: String) -> NutritionInfo? {
        let key = normalized(foodName)
        guard let entry = storage[key] else { return nil }
        guard Date().timeIntervalSince(entry.timestamp) <= entryLifetime else {
            storage.removeValue(forKey: key)
            persist()
            return nil
        }
        return entry.info
    }
    
    /// Persist a nutrition response for future reuse
    func store(_ info: NutritionInfo, for foodName: String) {
        let key = normalized(foodName)
        storage[key] = CachedEntry(info: info, timestamp: Date())
        persist()
    }
    
    /// Clear all cached entries (used for debugging or logout flows)
    func clear() {
        storage.removeAll()
        persist()
    }
    
    // MARK: - Private
    
    private let userDefaults: UserDefaults
    
    private func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(storage) {
            userDefaults.set(data, forKey: storageKey)
        }
    }
}
