//
//  PokemonViewModel.swift
//  PokemonApp
//
//  Created by Cristopher Escorcia on 25/06/21.
//

import SwiftUI
import Combine

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var isLoading: Bool = false
    
    private var subscribers: Set<AnyCancellable> = []
    
    let limit: Int
    let offset: Int
    let interactor: PokemonRepositoryType
    
    init(limit: Int,
         offset: Int,
         interactor: PokemonRepositoryType = PokemonRepositoryInteractor()
    ) {
        self.limit = limit
        self.offset = offset
        self.interactor = interactor
        fetchPokemons()
    }
    
    func fetchPokemons() {
        self.isLoading = true
        
        interactor.getPokemonsURLFromAGeneration(limit: limit, offset: offset)?
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    // IDK WHAT TO DO HERE
                    break
                case .failure(let error):
                    self?.isLoading = false
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] pokedex in
                for pokemon in pokedex.results {
                    self?.getSinglePokemon(url: pokemon.url ?? "")
                }
            }
            .store(in: &subscribers)
    }
    
    func getSinglePokemon(url: String) {
        interactor.getASinglePokemon(url: url)?
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    // IDK WHAT TO DO HERE
                    break
                case .failure(let error):
                    self?.isLoading = false
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] pokemon in
                self?.pokemons.append(pokemon)
                self?.pokemons.sort { $0.id < $1.id }
                self?.isLoading = false
            }
            .store(in: &subscribers)
    }
}
