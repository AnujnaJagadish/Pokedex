//
//  PokemonAPIService.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/3/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
}

class PokemonAPIService {
    static let shared = PokemonAPIService()
    private let baseURL = "https://pokeapi.co/api/v2"
    
    private init() {}
    
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> PokemonListResponse {
        let endpoint = "/pokemon?limit=\(limit)&offset=\(offset)"
        return try await performRequest(endpoint: endpoint, responseType: PokemonListResponse.self)
    }
    
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        let endpoint = "/pokemon/\(id)"
        return try await performRequest(endpoint: endpoint, responseType: PokemonDetail.self)
    }
    
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
        } catch {
            throw APIError.networkError(error)
        }
    }
}

extension PokemonAPIService {
    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies {
        let endpoint = "/pokemon-species/\(id)"
        return try await performRequest(endpoint: endpoint, responseType: PokemonSpecies.self)
    }
    
    private func extractIdFromUrl(_ url: String) -> Int {
        let components = url.split(separator: "/")
        if let idString = components.last, let id = Int(idString) {
            return id
        }
        return 0
    }
}
