//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/1/25.
import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: CaughtPokemon.self, PokemonTeam.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
