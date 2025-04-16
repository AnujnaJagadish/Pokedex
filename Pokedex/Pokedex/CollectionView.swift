//
//  CollectionView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/8/25.
//
import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var caughtPokemon: [CaughtPokemon]
    @Query(sort: \PokemonTeam.dateCreated, order: .reverse, animation: .default)
    private var teams: [PokemonTeam]
    
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var typeFilter: String? = nil
    @State private var showingNewTeamSheet = false
    
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
            contentView
            .navigationTitle("My Collection")
            .refreshable {
            }
            .toolbar {
                if selectedTab == 2 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingNewTeamSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNewTeamSheet) {
                CreateTeamView(caughtPokemon: Array(caughtPokemon))
            }
        }
    }
    
    private var contentView: some View {
        VStack {
            if caughtPokemon.isEmpty && selectedTab != 2 {
                emptyCollectionView
            } else {
                Picker("View", selection: $selectedTab) {
                    Text("Caught").tag(0)
                    Text("Favorites").tag(1)
                    Text("Teams").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if selectedTab == 2 {
                    teamsView
                } else {
                    typeFilterView
                    pokemonListView
                }
            }
        }
    }
    
    private var filteredTeams: [PokemonTeam] {
            searchText.isEmpty ? teams : teams.filter { team in
                team.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        private var teamsView: some View {
            VStack {
                Text("Teams: \(teams.map { $0.name }.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if teams.isEmpty {
                    VStack(spacing: 20) {
                        Text("No Teams Created")
                            .font(.title2)
                        
                        Text("Create a team to organize your Pokémon and analyze their strengths and weaknesses.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingNewTeamSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create New Team")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredTeams) { team in
                            NavigationLink {
                                TeamDetailView(team: team, caughtPokemon: Array(caughtPokemon))
                            } label: {
                                TeamRowView(team: team, caughtPokemon: Array(caughtPokemon))
                            }
                            .swipeActions(edge: .trailing) {
                                       Button(role: .destructive) {
                                           deleteTeam(team)
                                       } label: {
                                           Label("Delete", systemImage: "trash")
                                       }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search teams")
                    Button("Refresh Teams") {
                        try? modelContext.save()
                    }
                    .padding()
                }
            }
        }
    
    private func deleteTeam(_ team: PokemonTeam) {
        modelContext.delete(team)
        try? modelContext.save()
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
                NavigationLink {
                               PokemonDetailView(pokemonId: pokemon.id)
                           } label: {
                               pokemonRow(for: pokemon)
                           }
                    .swipeActions {
                        Button(role: .destructive) {
                            deletePokemon(pokemon)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            toggleFavorite(pokemon: pokemon)
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
    
    private func deletePokemon(_ pokemon: CaughtPokemon) {
        modelContext.delete(pokemon)
        do {
               let teamDescriptor = FetchDescriptor<PokemonTeam>()
               let teams = try modelContext.fetch(teamDescriptor)

               for team in teams {
                   team.pokemonIDs.removeAll { $0 == pokemon.id }
               }
               
        try? modelContext.save()
        } catch {
               print("Error cleaning up teams after deleting Pokemon: \(error)")
           }
    }
    
    private func toggleFavorite(pokemon: CaughtPokemon) {
        pokemon.isFavorite.toggle()
        try? modelContext.save()
    }
}

struct TeamRowView: View {
    let team: PokemonTeam
    let caughtPokemon: [CaughtPokemon]
    
    var teamPokemon: [CaughtPokemon] {
        caughtPokemon.filter { team.pokemonIDs.contains($0.id) }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(team.name)
                    .font(.headline)
                
                Text("\(team.pokemonIDs.count) Pokémon")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: -10) {
                ForEach(Array(teamPokemon.prefix(3).enumerated()), id: \.element.id) { index, pokemon in
                    if let spriteURL = pokemon.spriteURL, let url = URL(string: spriteURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 35, height: 35)
                                    .background(Circle().fill(Color.white))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 35, height: 35)
                            }
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 35, height: 35)
                    }
                }
                
                if team.pokemonIDs.count > 3 {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 35, height: 35)
                        .overlay(
                            Text("+\(team.pokemonIDs.count - 3)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
            }
        }
    }

}

#Preview {
    let container = try! ModelContainer(
        for: CaughtPokemon.self, PokemonTeam.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext
    let previewTeam1 = PokemonTeam(name: "Indigo Team")
    let previewTeam2 = PokemonTeam(name: "Jhoto Four")
    
    do {
        context.insert(previewTeam1)
        context.insert(previewTeam2)
        try context.save()
    } catch {
        print("Error inserting preview teams: \(error)")
    }
    
    return CollectionView()
        .modelContainer(container)
}

