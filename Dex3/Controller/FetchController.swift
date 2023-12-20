

import Foundation
import CoreData

struct FetchController {
    enum NetworkError: Error {
        case badURL, badResponse, badData
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")
    
    func fetchAllPokemon() async throws -> [TempPokemon]? {
        if pokemonExists() {
            return nil
        }
        
        var allPokemon: [TempPokemon] = []
        
        guard let baseURL else {
            throw NetworkError.badURL
        }
        
        var fetchComponents = URLComponents(
            url: baseURL,
            resolvingAgainstBaseURL: true
        )
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "386")]
        
        guard let fetURl = fetchComponents?.url else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetURl)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let pokedex = pokeDictionary["results"] as? [[String: String]]
        else {
            throw NetworkError.badData
        }
        
        for pokemon in pokedex {
            if let urlString = pokemon["url"],
               let url = URL(string: urlString) {
                allPokemon.append(try await fetchPokemonDetails(from: url))
            }
        }
        
        return allPokemon
    }
    
    private func fetchPokemonDetails(from url: URL) async throws -> TempPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        let tempPokemon = try JSONDecoder().decode(TempPokemon.self, from: data)
        
        print("Fetched \(tempPokemon.id): \(tempPokemon.name)")
        
        return tempPokemon
    }
    
    private func pokemonExists() -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])
        
        do {
            let checkPokemon = try context.fetch(fetchRequest)
            return checkPokemon.count == 2
        } catch {
            print("Fetch Failed")
            return false
        }
    }
}
