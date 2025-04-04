//
//  PokedexListView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/2/25.
//

import SwiftUI
import SwiftData

struct PokedexListView: View {
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var pokemonList: [PokemonListItem] = []
    @State private var typeFilter: String? = nil
    @State private var pokemonTypes: [String] = []
    @State private var pokemonTypeCache: [Int: [String]] = [:]
    
    var filteredPokemon: [PokemonListItem] {
        var filtered = pokemonList
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let typeFilter = typeFilter {
            filtered = filtered.filter { pokemon in
                if let types = pokemonTypeCache[pokemon.id] {
                    return types.contains { $0.lowercased() == typeFilter.lowercased() }
                }
                return true
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading Pokémon...")
                } else if let error = errorMessage {
                    VStack {
                        Text("Something went wrong")
                            .font(.headline)
                        Text("We couldn't load the Pokémon data. Please try again.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("Retry") {
                            Task {
                                await loadPokemon()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                } else {
                    HStack {
                        Text("Filter by type:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Menu {
                            Button("All Types") {
                                typeFilter = nil
                            }
                            
                            Divider()
                            
                            ForEach(pokemonTypes.sorted(), id: \.self) { type in
                                Button(type.capitalized) {
                                    typeFilter = type
                                }
                            }
                        } label: {
                            HStack {
                                Text(typeFilter?.capitalized ?? "All")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    List(filteredPokemon) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemonId: pokemon.id)) {
                                HStack {
                                    Text("\(pokemon.id)")
                                        .foregroundColor(.secondary)
                                        .frame(width: 35)
                                    
                                    Text(pokemon.name.capitalized)
                                    
                                    Spacer()
                                }
                        }
                        .task {
                            if pokemonTypeCache[pokemon.id] == nil {
                                await loadPokemonType(for: pokemon)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search Pokémon")
                }
            }
            .navigationTitle("Pokédex")
            .task {
                if pokemonList.isEmpty {
                    await loadPokemon()
                }
            }
        }
    }

    
    func loadPokemon() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await PokemonAPIService.shared.fetchPokemonList(limit: 250)
            pokemonList = response.results
        }
        catch let apiError as APIError {
                errorMessage = apiError.customErrorMessage
                print("Debug error: \(apiError)")
            }
        catch {
                errorMessage = "Something unexpected happened. Please try again later."
                print("Unexpected error: \(error)")
            }
        
        isLoading = false
    }
    func loadPokemonType(for pokemon: PokemonListItem) async {
        if pokemonTypeCache[pokemon.id] != nil {
            return
        }
        
        do {
            let details = try await PokemonAPIService.shared.fetchPokemonDetail(id: pokemon.id)
            let types = details.types.map { $0.type.name }
            
            pokemonTypeCache[pokemon.id] = types
            
            for type in types {
                if !pokemonTypes.contains(type) {
                    pokemonTypes.append(type)
                }
            }
        } catch {
            print("Error loading type for \(pokemon.name): \(error)")
        }
    }
}

#Preview {
        PokedexListView()
            .modelContainer(for: [CaughtPokemon.self], inMemory: true)
}
