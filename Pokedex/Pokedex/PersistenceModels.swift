//
//  PersistenceModels.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/3/25.
//

import Foundation
import SwiftData

@Model
class CaughtPokemon {
    var id: Int
    var name: String
    var types: [String]
    var spriteURL: String?
    var isFavorite: Bool
    var dateAdded: Date
    
    init(id: Int, name: String, types: [String], spriteURL: String? = nil, isFavorite: Bool, dateAdded: Date) {
        self.id = id
        self.name = name
        self.types = types
        self.spriteURL = spriteURL
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
    }
}
