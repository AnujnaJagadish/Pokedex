//
//  PokemonDataManager.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/8/25.
//
import SwiftData
import Foundation

@MainActor
final class PokemonDataManager: ObservableObject {
    static let shared = PokemonDataManager()
    private var container: ModelContainer?
    private var modelContext: ModelContext?
    
    @Published var lastUpdate = Date()
    
    private init() {
        do {
            container = try ModelContainer(for: CaughtPokemon.self)
            modelContext = container?.mainContext
        } catch {
            print("Failed to create container: \(error)")
        }
    }
    
    func setSharedModelContainer(_ container: ModelContainer) {
        self.container = container
        self.modelContext = container.mainContext
    }
    
    func catchPokemon(id: Int, name: String, types: [String], spriteURL: String?) async {
        guard let modelContext else { return }
        
        let descriptor = FetchDescriptor<CaughtPokemon>(predicate: #Predicate { $0.id == id })
        if let _ = try? modelContext.fetch(descriptor).first {
            return
        }
        
        let newPokemon = CaughtPokemon(
            id: id,
            name: name,
            types: types,
            spriteURL: spriteURL,
            isFavorite: false,
            dateAdded: Date()
        )
        modelContext.insert(newPokemon)
        try? modelContext.save()
        lastUpdate = Date()
    }
    
    func toggleFavorite(id: Int, name: String, types: [String], spriteURL: String?, isCaught: Bool) async {
        guard let modelContext else { return }
        
        let descriptor = FetchDescriptor<CaughtPokemon>(predicate: #Predicate { $0.id == id })
        if let existingPokemon = try? modelContext.fetch(descriptor).first {
            existingPokemon.isFavorite.toggle()
            try? modelContext.save()
            lastUpdate = Date()
            return
        }
        
        if !isCaught {
            let newPokemon = CaughtPokemon(
                id: id,
                name: name,
                types: types,
                spriteURL: spriteURL,
                isFavorite: true,
                dateAdded: Date()
            )
            modelContext.insert(newPokemon)
            try? modelContext.save()
            lastUpdate = Date()
        }
    }
    
    func getCaughtPokemon() async -> [CaughtPokemon] {
        guard let modelContext else { return [] }
        let descriptor = FetchDescriptor<CaughtPokemon>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func deletePokemon(_ pokemon: CaughtPokemon) async {
        guard let modelContext else { return }
        modelContext.delete(pokemon)
        try? modelContext.save()
        lastUpdate = Date()
    }
}
