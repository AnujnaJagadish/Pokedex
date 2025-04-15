//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/8/25.
//
import Foundation
import Observation

@Observable
@MainActor
class PokemonDetailViewModel {
    private let pokemonId: Int
    
    init(pokemonId: Int) {
        self.pokemonId = pokemonId
    }
    
    func fetchPokemonDetails() async throws -> PokemonDetail {
        return try await PokemonAPIService.shared.fetchPokemonDetail(id: pokemonId)
    }
    
    func fetchEvolutionChain(for pokemonId: Int) async throws -> [PokemonEvolution] {
        return try await PokemonAPIService.shared.getEvolutionChain(for: pokemonId)
    }
}
