//
//  CreateTeamView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/14/25.
//
import SwiftUI
import SwiftData

@MainActor
struct CreateTeamView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var teamName = "New Team"
    @State private var selectedPokemonIDs: [Int] = []
    let caughtPokemon: [CaughtPokemon]
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Team Name", text: $teamName)
                    .font(.headline)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                List {
                    ForEach(caughtPokemon) { pokemon in
                        Button(action: {
                            toggleSelection(for: pokemon.id)
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
                                
                                Spacer()
                                
                                if selectedPokemonIDs.contains(pokemon.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .disabled(selectedPokemonIDs.count >= 6 && !selectedPokemonIDs.contains(pokemon.id))
                    }
                }
                
                Text("Selected \(selectedPokemonIDs.count)/6 Pokémon")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .navigationTitle("Create New Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createTeam()
                    }
                    .disabled(selectedPokemonIDs.isEmpty || teamName.isEmpty)
                }
            }
        }
    }
    
    private func toggleSelection(for id: Int) {
        if let index = selectedPokemonIDs.firstIndex(of: id) {
            selectedPokemonIDs.remove(at: index)
        } else if selectedPokemonIDs.count < 6 {
            selectedPokemonIDs.append(id)
        }
    }
    
    private func createTeam() {
        print("Creating team: \(teamName) with \(selectedPokemonIDs.count) Pokémon")
        let newTeam = PokemonTeam(name: teamName, pokemonIDs: selectedPokemonIDs)
        modelContext.insert(newTeam)
        
        do {
            try modelContext.save()
            print("Team saved successfully with ID: \(newTeam.id)")
        } catch {
            print("Failed to save team: \(error)")
        }
        
        dismiss()
    }
}

#Preview {
   CreateTeamView(caughtPokemon: [])
       .modelContainer(for: [CaughtPokemon.self, PokemonTeam.self], inMemory: true)
}
