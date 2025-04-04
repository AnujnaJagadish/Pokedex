### Pokedex
A Swift based Pokémon App

## Introduction
Pokémon companion app that allows users to browse the complete Pokédex, search and
filter Pokémon by various attributes, and maintain a personal collection of caught and
favorite Pokémon with custom team-building capabilities.
• The app will store caught Pokémon, favorite Pokémon, and custom teams using
SwiftData
• Each caught Pokémon will store the complete data model or reference ID for quick
retrieval

## API: https://pokeapi.co/api
# UI: 
    So far:
    • Tab1 - Home Dashboard
        ◦ Quick access buttons to main app functions
    • Tab2 - Pokédex
        ◦ Stack2A: List of all Pokémon using GET /api/v2/pokemon
            ▪ Searchable on "name"
            ▪ Filterable on "type"
            ▪ Shows basic information such as Id, name
            ▪ Selecting a Pokémon navigates to Stack2B
        ◦ Stack2B: Detailed Pokémon information using GET /api/v2/pokemon/{id}
            ▪ Shows comprehensive stats, abilities, and type information
            ▪ "Catch" button to add to collection
            ▪ "Favorite" button to mark as favorite