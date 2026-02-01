//
//  Item.swift
//  food2fit
//
//  Created by zhanghe on 2026/2/1.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
