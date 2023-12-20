

import Foundation
import SwiftUI

extension Pokemon {
    var background: ImageResource {
        guard let types = self.types else {
            return .normalgrasselectricpoisonfairy
        }
        
        switch types[0] {
        case "normal", "grass", "electric", "poison", "fairy":
            return .normalgrasselectricpoisonfairy
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
            return .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
            return .firedragon
        case "flying", "bug":
            return .flyingbug
        case "ice":
            return .ice
        case "water":
            return .water
        default:
            return .normalgrasselectricpoisonfairy
        }
    }
    
    var stats: [Stat] {
        [
            Stat(id: 1, label: "HP", value: self.hp),
            Stat(id: 2, label: "Attack", value: self.attack),
            Stat(id: 3, label: "Defense", value: self.defense),
            Stat(id: 4, label: "Special Attack", value: self.specialAttack),
            Stat(id: 5, label: "Special Defense", value: self.specialDefense),
            Stat(id: 6, label: "Speed", value: self.speed)
        ]
    }
    
    var highestStat: Stat {
        stats.max { $0.value < $1.value } ?? Stat(id: 0, label: "Error", value: 0)
    }
    
    func organizedTypes() -> [String] {
        guard var types = self.types else {
            return [""]
        }
        
        if types.count == 2 && types[0] == "normal" {
            types.swapAt(0, 1)
        }
        
        return types
    }
}

struct Stat: Identifiable {
    let id: Int
    let label: String
    let value: Int16
}
