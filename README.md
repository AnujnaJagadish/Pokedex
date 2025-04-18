## Pokedex
A Swift based Pokémon App

### Introduction
Pokémon companion app that allows users to browse the complete Pokédex, search and
filter Pokémon by various attributes, and maintain a personal collection of caught and
favorite Pokémon with custom team-building capabilities.
• The app will store caught Pokémon, favorite Pokémon, and custom teams using
SwiftData
• Each caught Pokémon will store the complete data model or reference ID for quick
retrieval

### API: https://pokeapi.co/api
### UI: 
    • Tab1 - Home Dashboard
        ◦ Quick access buttons to main app functions
    • Tab2 - Pokédex
        ◦ Stack2A: List of all Pokémon using GET /api/v2/pokemon
            ▪ Searchable on "name"
            ▪ Filterable on "type"
            ▪ Shows basic information such as Id, name
            ▪ Selecting a Pokémon navigates to Stack2B
        ◦ Stack2B: Detailed Pokémon information using GET /api/v2/pokemon/{id}
            ▪ Have 2 tabs Stats & Evolution
            ▪ Stats tab shows comprehensive stats, abilities, and type information
            ▪ Evolution tab shows evolution chain, evolutionFrom -> evolutionTo
            ▪ "Favorite" button to mark as favorite
            ▪ "Catch" button to add to collection
            ▪ "Favorite" button to mark as favorite
    • Tab3 - My Collection
        ◦ Stack3A: List of caught Pokémon retrieved from Data stored
            ▪ Searchable on name
            ▪ Filterable by type
            ▪ 3 Tabs - All , Favorites and Teams Management
        ◦ Stack3B: Create Teams
            ▪ Display created teams
            ▪ Allow adding/deleting Pokémon from teams
            ▪ Show team type effectiveness analysis
    • Tab4 - Quiz
        ◦ Stack4A: Hardcoded set of Pokemon-related questions
            ▪ Tracks the user's score throughout the quiz 
            ▪ Shows a results screen with a message based on performance & allows re-take
            


