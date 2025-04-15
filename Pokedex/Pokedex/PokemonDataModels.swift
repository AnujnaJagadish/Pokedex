//
//  PokemonDataModels.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/14/25.
//
import Foundation
import SwiftData

@Model
final class CaughtPokemon {
    @Attribute(.unique) var id: Int
    var name: String
    var types: [String]
    var spriteURL: String?
    var isFavorite: Bool
    var dateAdded: Date
    
    init(id: Int, name: String, types: [String], spriteURL: String? = nil,
         isFavorite: Bool, dateAdded: Date) {
        self.id = id
        self.name = name
        self.types = types
        self.spriteURL = spriteURL
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
    }
}

@Model
final class PokemonTeam {
    @Attribute(.unique) var id: UUID
    var name: String
    var pokemonIDs: [Int]
    var dateCreated: Date
    
    init(name: String, pokemonIDs: [Int] = []) {
        self.id = UUID()
        self.name = name
        self.pokemonIDs = pokemonIDs
        self.dateCreated = Date()
    }
}
