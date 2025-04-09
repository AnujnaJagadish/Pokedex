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
            CollectionView().tabItem {
                Label("My Collection",
                      systemImage: "folder.fill.badge.plus")
            }
            PokemonQuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CaughtPokemon.self], inMemory: true)
}
