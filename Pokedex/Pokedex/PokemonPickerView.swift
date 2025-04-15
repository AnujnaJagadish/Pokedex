//
//  PokemonPickerView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/14/25.
//
import SwiftUI
import SwiftData

struct PokemonPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let team: PokemonTeam
    let caughtPokemon: [CaughtPokemon]
    @State private var searchText = ""
    @State private var showTeamFullAlert = false
    
    var availablePokemon: [CaughtPokemon] {
        let filtered = searchText.isEmpty ? caughtPokemon : caughtPokemon.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
        return filtered.filter { !team.pokemonIDs.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if availablePokemon.isEmpty {
                    ContentUnavailableView {
                        Label("No Available Pokémon", systemImage: "pawprint.fill")
                    } description: {
                        if searchText.isEmpty {
                            Text("All caught Pokémon are already in this team")
                        } else {
                            Text("No Pokémon match your search")
                        }
                    }
                } else {
                    ForEach(availablePokemon) { pokemon in
                        Button(action: {
                            addPokemonToTeam(pokemon)
                        }) {
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
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Pokémon")
            .navigationTitle("Add to Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Team Full", isPresented: $showTeamFullAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You can only add up to 6 Pokémon to a team.")
            }
        }
    }
    
    private func addPokemonToTeam(_ pokemon: CaughtPokemon) {
        if team.pokemonIDs.count >= 6 {
            showTeamFullAlert = true
            return
        }
        
        if !team.pokemonIDs.contains(pokemon.id) {
            team.pokemonIDs.append(pokemon.id)
            do {
                try modelContext.save()
                dismiss()
            } catch {
                print("Failed to save Pokemon to team: \(error)")
                // Optionally, you could show an error alert here
            }
        }
    }
}

#Preview {
    let previewTeam = PokemonTeam(name: "Test Team")
    return PokemonPickerView(team: previewTeam, caughtPokemon: [])
        .modelContainer(for: [CaughtPokemon.self, PokemonTeam.self], inMemory: true)
}
