//
//  PokemonAPIService.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/1/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    
    var customErrorMessage: String {
        switch self {
        case .invalidURL:
            return "We couldn't connect to the Pokémon database. Please try again later."
        case .invalidResponse:
            return "The Pokémon server isn't responding correctly. Please try again later."
        case .decodingError:
            return "We couldn't understand the data from the Pokémon database. Please try again later."
        case .networkError(let error):
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return "You're not connected to the internet. Please check your connection and try again."
                case .timedOut:
                    return "The connection timed out. Please try again later."
                default:
                    return "There was a problem with your internet connection. Please try again."
                }
            }
            return "There was a problem connecting to the Pokémon database. Please try again later."
        }
    }
}

class PokemonAPIService: @unchecked Sendable {
    static let shared = PokemonAPIService()
    private let baseURL = "https://pokeapi.co/api/v2"
    
    private init() {}
    
    @PokemonActor
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> PokemonListResponse {
        let endpoint = "/pokemon?limit=\(limit)&offset=\(offset)"
        return try await performRequest(endpoint: endpoint, responseType: PokemonListResponse.self)
    }
    
    @PokemonActor
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        let endpoint = "/pokemon/\(id)"
        return try await performRequest(endpoint: endpoint, responseType: PokemonDetail.self)
    }
    
    @PokemonActor
    func fetchPokemonDetail(name: String) async throws -> PokemonDetail {
        let endpoint = "/pokemon/\(name.lowercased())"
        return try await performRequest(endpoint: endpoint, responseType: PokemonDetail.self)
    }
    
    private func performRequest<T: Decodable>(endpoint: String, responseType: T.Type) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(responseType, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    @PokemonActor
    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies {
        let endpoint = "/pokemon-species/\(id)"
        return try await performRequest(endpoint: endpoint, responseType: PokemonSpecies.self)
    }
    
    @PokemonActor
    func fetchEvolutionChain(url: String) async throws -> EvolutionChain {
        guard let url = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(EvolutionChain.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    @PokemonActor
    func getEvolutionChain(for pokemonId: Int) async throws -> [PokemonEvolution] {
        let species = try await fetchPokemonSpecies(id: pokemonId)
        
        let evolutionChain = try await fetchEvolutionChain(url: species.evolutionChain.url)
        
        var evolutions: [PokemonEvolution] = []
        
        let baseSpecies = evolutionChain.chain.species
        let baseId = extractIdFromUrl(baseSpecies.url)
        evolutions.append(PokemonEvolution(
            id: baseId,
            name: baseSpecies.name,
            imageURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(baseId).png",
            level: 0
        ))
        
        processEvolutions(chainLink: evolutionChain.chain, evolutions: &evolutions)
        
        return evolutions
    }
    
    private func processEvolutions(chainLink: ChainLink, evolutions: inout [PokemonEvolution]) {
        for evolution in chainLink.evolvesTo {
            let evoId = extractIdFromUrl(evolution.species.url)
            let level = evolution.evolutionDetails.first?.minLevel ?? 0
            
            evolutions.append(PokemonEvolution(
                id: evoId,
                name: evolution.species.name,
                imageURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(evoId).png",
                level: level
            ))
            
            processEvolutions(chainLink: evolution, evolutions: &evolutions)
        }
    }
    
    private func extractIdFromUrl(_ url: String) -> Int {
        let components = url.split(separator: "/")
        if let idString = components.last, let id = Int(idString) {
            return id
        }
        return 0
    }
}

