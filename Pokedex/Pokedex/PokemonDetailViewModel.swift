//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/8/25.
//
import Foundation

class PokemonDetailViewModel {
    private let pokemonId: Int
    
    init(pokemonId: Int) {
        self.pokemonId = pokemonId
    }
    
    @MainActor
    func fetchPokemonDetails() async throws -> PokemonDetail {
        return try await PokemonAPIService.shared.fetchPokemonDetail(id: pokemonId)
    }
    
    @MainActor
    func fetchEvolutionChain(for pokemonId: Int) async throws -> [PokemonEvolution] {
        return try await PokemonAPIService.shared.getEvolutionChain(for: pokemonId)
    }
    
    func catchPokemon(pokemon: PokemonDetail) {
        print("Caught \(pokemon.name)")
    }
    
    func toggleFavorite(pokemon: PokemonDetail) {
        print("Toggled favorite for \(pokemon.name)")
    }
}
