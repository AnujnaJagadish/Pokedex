//
//  CollectionView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/8/25.
//
import SwiftUI
import SwiftData

struct CollectionView: View {
    @State private var caughtPokemon: [CaughtPokemon] = []
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var typeFilter: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @StateObject private var dataManager = PokemonDataManager.shared
    
    var filteredPokemon: [CaughtPokemon] {
        var filtered = searchText.isEmpty ? caughtPokemon : caughtPokemon.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        
        if let typeFilter = typeFilter {
            filtered = filtered.filter { $0.types.contains { $0.lowercased() == typeFilter.lowercased() } }
        }
        
        switch selectedTab {
        case 0: return filtered
        case 1: return filtered.filter { $0.isFavorite }
        default: return filtered
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                } else {
                    contentView
                }
            }
            .navigationTitle("My Collection")
            .task { await loadPokemon() }
            .refreshable { await loadPokemon() }
            .onChange(of: dataManager.lastUpdate) { _, _ in
                Task {
                    await loadPokemon()
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack {
            if caughtPokemon.isEmpty {
                emptyCollectionView
            } else {
                Picker("View", selection: $selectedTab) {
                    Text("All").tag(0)
                    Text("Favorites").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                typeFilterView
                pokemonListView
            }
        }
    }
    
    private func loadPokemon() async {
        isLoading = true
        errorMessage = nil
        do {
            caughtPokemon = await dataManager.getCaughtPokemon()
            print("Loaded \(caughtPokemon.count) Pokémon")
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading Pokémon: \(error)")
        }
        isLoading = false
    }
    
    private var emptyCollectionView: some View {
        VStack {
            Text("Your collection is empty")
                .font(.title2)
            Text("Catch some Pokémon to see them here!")
                .foregroundColor(.secondary)
            
            NavigationLink(destination: PokedexListView()) {
                Text("Go to Pokédex")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.top)
            }
        }
        .padding()
    }
    
    private var typeFilterView: some View {
        HStack {
            Text("Filter by type:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Menu {
                Button("All Types") {
                    typeFilter = nil
                }
                
                Divider()
                
                let types = Array(Set(caughtPokemon.flatMap { $0.types })).sorted()
                
                ForEach(types, id: \.self) { type in
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
    }
    
    private var pokemonListView: some View {
        List {
            ForEach(filteredPokemon) { pokemon in
                pokemonRow(for: pokemon)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await deletePokemon(pokemon)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            Task {
                                await toggleFavorite(pokemon: pokemon)
                            }
                        } label: {
                            Label(pokemon.isFavorite ? "Unfavorite" : "Favorite",
                                  systemImage: pokemon.isFavorite ? "star.slash" : "star")
                        }
                        .tint(.yellow)
                    }
            }
        }
        .searchable(text: $searchText, prompt: "Search your collection")
    }
    
    private func pokemonRow(for pokemon: CaughtPokemon) -> some View {
        HStack {
            if let spriteURL = pokemon.spriteURL, let url = URL(string: spriteURL) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                    }
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading) {
                Text(pokemon.name.capitalized)
                    .font(.headline)
                Text(pokemon.types.map { $0.capitalized }.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if pokemon.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
    }
    
    private func deletePokemon(_ pokemon: CaughtPokemon) async {
        await dataManager.deletePokemon(pokemon)
        await loadPokemon()
    }
    
    private func toggleFavorite(pokemon: CaughtPokemon) async {
        await dataManager.toggleFavorite(
            id: pokemon.id,
            name: pokemon.name,
            types: pokemon.types,
            spriteURL: pokemon.spriteURL,
            isCaught: true
        )
        await loadPokemon()
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: [CaughtPokemon.self], inMemory: true)
}

