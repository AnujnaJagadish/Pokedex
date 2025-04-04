//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/3/25.
//

import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CaughtPokemon.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
