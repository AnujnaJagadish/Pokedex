//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/1/25.
import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [CaughtPokemon.self, PokemonTeam.self])
        }
    }
}
