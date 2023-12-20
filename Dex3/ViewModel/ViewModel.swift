
import Foundation

@MainActor
class ViewModel: ObservableObject {
    enum Status {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    @Published private(set) var status: Status = .notStarted
    
    private let controller: FetchController
    
    init(controller: FetchController) {
        self.controller = controller
        
        Task {
            await getPokemons()
        }
    }
    
    private func getPokemons() async {
        status = .fetching
        
        do {
            guard var pokedex = try await controller.fetchAllPokemon() else {
                print("Display Pokemons from database")
                status = .success
                return
            }
            
            pokedex.sort { $0.id < $1.id }
            
            for pokemon in pokedex {
                let newPokemon = Pokemon(context: PersistenceController.shared.container.viewContext)
                newPokemon.id = Int16(pokemon.id)
                newPokemon.name = pokemon.name
                newPokemon.types = pokemon.types
                newPokemon.types = newPokemon.organizedTypes()
                newPokemon.hp = Int16(pokemon.hp)
                newPokemon.attack = Int16(pokemon.attack)
                newPokemon.defense = Int16(pokemon.defense)
                newPokemon.specialAttack = Int16(pokemon.specialAttack)
                newPokemon.specialDefense = Int16(pokemon.specialDefense)
                newPokemon.speed = Int16(pokemon.speed)
                newPokemon.sprite = pokemon.sprite
                newPokemon.shinySprite = pokemon.shinySprite
                newPokemon.favorite = false
                
                try PersistenceController.shared.container.viewContext.save()
            }
            
            status = .success
        } catch {
            status = .failed(error: error)
        }
    }
}
