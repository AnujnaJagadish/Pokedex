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
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

