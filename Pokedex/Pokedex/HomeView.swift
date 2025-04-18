//
//  HomeView.swift
//  Pokedex
//
//  Created by Anujna Ashwath on 4/1/25.
//

import SwiftUI
import SwiftData

struct HomeView: View
{
    var body: some View
    {
        NavigationStack
        {
            VStack(spacing: 70)
            {
                Text("Home")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                Image("HomePage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 800,
                           height: 300)
                
                VStack(spacing: 0)
                {
                    Text("Welcome to\nPickachu's PokéDex!")
                        .font(.title)
                        .bold()
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    Text("Your Pokémon companion app")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [CaughtPokemon.self, PokemonTeam.self], inMemory: true)
}
