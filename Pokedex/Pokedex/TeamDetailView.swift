//
//  TeamDetailView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/14/25.
//
import SwiftUI
import SwiftData

struct TeamDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var team: PokemonTeam
    let caughtPokemon: [CaughtPokemon]
    @State private var showingPokemonPicker = false
    
    var teamPokemon: [CaughtPokemon] {
        caughtPokemon.filter { team.pokemonIDs.contains($0.id) }
    }
    
    init(team: PokemonTeam, caughtPokemon: [CaughtPokemon]) {
        self._team = Bindable(wrappedValue: team)
        self.caughtPokemon = caughtPokemon
    }
    
    var body: some View {
        VStack {
            TextField("Team Name", text: $team.name)
                .font(.headline)
                .padding()
                .onChange(of: team.name) { _, _ in
                    saveChanges()
                }
            
            List {
                ForEach(teamPokemon) { pokemon in
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
                .onDelete(perform: removePokemonFromTeam)
                
                if teamPokemon.count < 6 {
                    Button(action: {
                        showingPokemonPicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add Pokémon to Team")
                        }
                    }
                }
            }
            
            Text("Team Strength Analysis")
                .font(.headline)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(getTeamTypeEffectiveness(), id: \.type) { typeEffect in
                        VStack {
                            Text(typeEffect.type.capitalized)
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Text(String(format: "%.1fx", typeEffect.effectiveness))
                                .font(.caption)
                                .foregroundColor(
                                    typeEffect.effectiveness > 1 ? .green :
                                    typeEffect.effectiveness < 1 ? .red : .primary
                                )
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Team Details")
        .sheet(isPresented: $showingPokemonPicker) {
            PokemonPickerView(team: team, caughtPokemon: caughtPokemon)
        }
    }
    
    private func removePokemonFromTeam(at offsets: IndexSet) {
        for index in offsets {
            let pokemonID = teamPokemon[index].id
            team.pokemonIDs.removeAll { $0 == pokemonID }
        }
        saveChanges()
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
            print("Team changes saved successfully")
        } catch {
            print("Failed to save team changes: \(error)")
        }
    }
    
    private func getTeamTypeEffectiveness() -> [TypeEffectiveness] {
        let types = ["fire", "water", "grass", "electric", "ground", "rock", "flying", "psychic"]
        var typeEffectiveness: [String: Double] = [:]
        
        for type in types {
            typeEffectiveness[type] = 1.0
        }
        
        for pokemon in teamPokemon {
            for pokemonType in pokemon.types {
                switch pokemonType.lowercased() {
                case "fire":
                    typeEffectiveness["grass", default: 1.0] += 0.5
                    typeEffectiveness["rock", default: 1.0] -= 0.5
                    typeEffectiveness["water", default: 1.0] -= 0.5

                case "water":
                    typeEffectiveness["fire", default: 1.0] += 0.5
                    typeEffectiveness["rock", default: 1.0] += 0.5
                    typeEffectiveness["electric", default: 1.0] -= 0.5
                    typeEffectiveness["grass", default: 1.0] -= 0.5

                case "grass":
                    typeEffectiveness["water", default: 1.0] += 0.5
                    typeEffectiveness["rock", default: 1.0] += 0.5
                    typeEffectiveness["fire", default: 1.0] -= 0.5
                    typeEffectiveness["flying", default: 1.0] -= 0.5

                case "electric":
                    typeEffectiveness["water", default: 1.0] += 0.5
                    typeEffectiveness["flying", default: 1.0] += 0.5
                    typeEffectiveness["ground", default: 1.0] -= 0.5
                    typeEffectiveness["grass", default: 1.0] -= 0.5

                case "ground":
                    typeEffectiveness["electric", default: 1.0] += 0.5
                    typeEffectiveness["fire", default: 1.0] += 0.5
                    typeEffectiveness["rock", default: 1.0] += 0.5
                    typeEffectiveness["grass", default: 1.0] -= 0.5
                    typeEffectiveness["water", default: 1.0] -= 0.5

                case "rock":
                    typeEffectiveness["fire", default: 1.0] += 0.5
                    typeEffectiveness["flying", default: 1.0] += 0.5
                    typeEffectiveness["water", default: 1.0] -= 0.5
                    typeEffectiveness["grass", default: 1.0] -= 0.5

                case "flying":
                    typeEffectiveness["grass", default: 1.0] += 0.5
                    typeEffectiveness["electric", default: 1.0] -= 0.5
                    typeEffectiveness["rock", default: 1.0] -= 0.5

                case "psychic":
                    typeEffectiveness["fighting", default: 1.0] += 0.5
                    typeEffectiveness["poison", default: 1.0] += 0.5
                    typeEffectiveness["psychic", default: 1.0] -= 0.5

                default:
                    break
                }
            }
        }
        
        return typeEffectiveness.map { TypeEffectiveness(type: $0.key, effectiveness: $0.value) }
    }
}

struct TypeEffectiveness {
    let type: String
    let effectiveness: Double
}

#Preview {
    let previewTeam = PokemonTeam(name: "Test Team")
    return TeamDetailView(team: previewTeam, caughtPokemon: [])
        .modelContainer(for: [CaughtPokemon.self, PokemonTeam.self], inMemory: true)
}
