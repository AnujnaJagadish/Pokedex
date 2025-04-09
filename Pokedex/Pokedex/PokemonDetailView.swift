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
    @ObservedObject private var viewModel: PokemonDetailViewModel
    
    @Query private var caughtPokemon: [CaughtPokemon]
    
    @State private var pokemon: PokemonDetail?
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var selectedTab = 0
    @State private var evolutionChain: [PokemonEvolution] = []
    @State private var isLoadingEvolution = false
    @State private var evolutionError: String? = nil
    @State private var showingCatchAlert = false
    @State private var showingFavoriteAlert = false
    
    var isCaught: Bool {
        guard let pokemon = pokemon else { return false }
        return caughtPokemon.contains(where: { $0.id == pokemon.id })
    }
    
    var isFavorite: Bool {
        guard let pokemon = pokemon else { return false }
        return caughtPokemon.contains(where: { $0.id == pokemon.id && $0.isFavorite })
    }
    
    init(pokemonId: Int) {
        self.pokemonId = pokemonId
        self.viewModel = PokemonDetailViewModel(pokemonId: pokemonId)
        

        self._caughtPokemon = Query()
    }
    
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
                        
                        Picker("Information", selection: $selectedTab) {
                            Text("Stats").tag(0)
                            Text("Evolution").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 8)
                        
                        if selectedTab == 0 {
                            statsView(for: pokemon)
                        } else {
                            evolutionChainView()
                        }
                        
                        HStack {
                            Button(action: {
                                Task {
                                    await PokemonDataManager.shared.catchPokemon(
                                        id: pokemon.id,
                                        name: pokemon.name,
                                        types: pokemon.types.map { $0.type.name },
                                        spriteURL: pokemon.sprites.frontDefault
                                    )
                                    showingCatchAlert = true
                                }
                            }) {
                                Text(isCaught ? "Caught" : "Catch")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(isCaught ? Color.gray : Color.green)
                                    .cornerRadius(12)
                            }
                            .disabled(isCaught)
                            
                            Button(action: {
                                Task {
                                    await PokemonDataManager.shared.toggleFavorite(
                                        id: pokemon.id,
                                        name: pokemon.name,
                                        types: pokemon.types.map { $0.type.name },
                                        spriteURL: pokemon.sprites.frontDefault,
                                        isCaught: isCaught
                                    )
                                    showingFavoriteAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: isFavorite ? "star.fill" : "star")
                                    Text("Favorite")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(isFavorite ? Color.yellow : Color.orange)
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
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 1 && evolutionChain.isEmpty && evolutionError == nil {
                Task {
                    await loadEvolutionChain()
                }
            }
        }
    }
    
    private func statsView(for pokemon: PokemonDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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
    }
        
    private func evolutionChainView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Evolution Chain")
                .font(.headline)
                .padding(.bottom, 2)
            
            if isLoadingEvolution {
                HStack {
                    Spacer()
                    ProgressView("Loading evolution data...")
                    Spacer()
                }
                .padding()
            } else if let error = evolutionError {
                VStack {
                    Text("Couldn't load evolution data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 2)
                    
                    Button("Try Again") {
                        Task {
                            await loadEvolutionChain()
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            } else if evolutionChain.isEmpty {
                Text("No evolution data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(evolutionChain, id: \.uniqueId) { evolution in
                            VStack {
                                if let imageURL = evolution.imageURL,
                                   let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 70, height: 70)
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 70, height: 70)
                                        }
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 70, height: 70)
                                }
                                
                                Text(evolution.name.capitalized)
                                    .font(.caption)
                                    .bold()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                pokemon?.id == evolution.id ?
                                    Color.yellow.opacity(0.2) :
                                    Color.gray.opacity(0.1)
                            )
                            .cornerRadius(12)

                            if evolution.id != evolutionChain.last?.id {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
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
    
    private func loadPokemonDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            pokemon = try await viewModel.fetchPokemonDetails()
        } catch let apiError as APIError {
            errorMessage = apiError.customErrorMessage
            print("Debug error: \(apiError)")
        } catch {
            errorMessage = "We couldn't load this Pokémon's details. Please try again."
        }
        
        isLoading = false
    }
    
    private func loadEvolutionChain() async {
        guard let pokemon = pokemon else { return }
        
        isLoadingEvolution = true
        evolutionError = nil
        
        do {
            evolutionChain = try await viewModel.fetchEvolutionChain(for: pokemon.id)
        } catch {
            evolutionError = "Error: \(error.localizedDescription)"
        }
        
        isLoadingEvolution = false
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView(pokemonId: 25) // Pikachu
            .modelContainer(for: [CaughtPokemon.self], inMemory: true)
    }
}
