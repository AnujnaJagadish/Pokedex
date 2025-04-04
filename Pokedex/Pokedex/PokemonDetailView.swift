//
//  PokemonDetailView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/3/25.
//

import SwiftUI
import SwiftData

struct PokemonDetailView: View {
    let pokemonId: Int
    @State private var pokemon: PokemonDetail?
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @State private var showingCatchAlert = false
    @State private var showingFavoriteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if isLoading {
                    ProgressView("Loading details...")
                        .padding()
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .padding()
                } else if let pokemon = pokemon {
                    VStack(spacing: 10) {
                        if let spriteURL = pokemon.sprites.frontDefault,
                           let url = URL(string: spriteURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 150, height: 150)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        
                        Text(pokemon.name.capitalized)
                            .font(.title)
                            .bold()
                      
                        Text("ID: \(pokemon.id)")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(20)
                        
                        HStack {
                            ForEach(pokemon.types, id: \.slot) { typeEntry in
                                Text(typeEntry.type.name.capitalized)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Abilities")
                                .font(.headline)
                            
                            HStack {
                                ForEach(pokemon.abilities, id: \.slot) { ability in
                                    Text(ability.ability.name.capitalized)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 5)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Stats")
                                .font(.headline)
                                .padding(.bottom, 7)
                            
                            ForEach(pokemon.stats, id: \.stat.name) { stat in
                                HStack {
                                    Text(stat.stat.name.capitalized)
                                        .frame(width: 70, alignment: .leading)
                                    Text("\(stat.baseStat)")
                                        .frame(width: 40, alignment: .trailing)
                                    ProgressView(value: Double(stat.baseStat), total: 100)
                                        .progressViewStyle(LinearProgressViewStyle(tint: statColor(for: stat.baseStat)))
                                }
                            }
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        HStack {
                            Button(action: {
                                showingCatchAlert = true
                            }) {
                                Text("Catch")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showingFavoriteAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "star")
                                    Text("Favorite")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(8)
                } else {
                    Text("No data available")
                        .padding()
                }
            }
        }
        .navigationTitle(pokemon?.name.capitalized ?? "Pokémon Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPokemonDetails()
        }
        .alert("Pokémon Caught!", isPresented: $showingCatchAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You caught \(pokemon?.name.capitalized ?? "the Pokémon")! Check your collection to see it.")
        }
        .alert("Added to Favorites", isPresented: $showingFavoriteAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(pokemon?.name.capitalized ?? "The Pokémon") has been added to your favorites!")
        }
    }
    
    private func statColor(for value: Int) -> Color {
        switch value {
        case 0..<50: return .red
        case 50..<80: return .orange
        case 80..<100: return .yellow
        case 100..<150: return .green
        default: return .blue
        }
    }
    
    func loadPokemonDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            pokemon = try await PokemonAPIService.shared.fetchPokemonDetail(id: pokemonId)
        }
        catch let apiError as APIError {
                errorMessage = apiError.customErrorMessage
                print("Debug error: \(apiError)")
            }
        catch {
            errorMessage = "We couldn't load this Pokémon's details. Please try again."
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView(pokemonId: 25) // Pikachu
            .modelContainer(for: [CaughtPokemon.self], inMemory: true)
    }
}
