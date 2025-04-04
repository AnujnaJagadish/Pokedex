//
//  PokemonModel.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/3/25.
//

import Foundation

struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}

struct PokemonListItem: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: Int {
        if let urlString = URL(string: url)?.pathComponents, urlString.count > 0 {
            if let idString = urlString.last, let id = Int(idString) {
                return id
            }
        }
        return 0
    }
}

struct PokemonDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [PokemonTypeEntry]
    let stats: [PokemonStat]
    let sprites: PokemonSprites
    let abilities: [PokemonAbility]
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: NamedAPIResource
}

struct PokemonStat: Codable {
    let baseStat: Int
    let effort: Int
    let stat: NamedAPIResource
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case effort
        case stat
    }
}

struct PokemonSprites: Codable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonAbility: Codable {
    let ability: NamedAPIResource
    let isHidden: Bool
    let slot: Int
    
    enum CodingKeys: String, CodingKey {
        case ability
        case isHidden = "is_hidden"
        case slot
    }
}

struct NamedAPIResource: Codable {
    let name: String
    let url: String
}

