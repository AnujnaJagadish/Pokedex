//
//  Item.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/1/25.
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
