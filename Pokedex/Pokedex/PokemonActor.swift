//
//  PokemonActor.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/14/25.
//
import Foundation

@globalActor actor PokemonActor {
    static let shared = PokemonActor()
    private init() {}
}
