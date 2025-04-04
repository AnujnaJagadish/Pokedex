//
//  ContentView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
            }
            PokedexListView()
                .tabItem {
                    Label("Pokédex", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CaughtPokemon.self], inMemory: true)
}
