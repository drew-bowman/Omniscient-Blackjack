//
//  Card.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/26/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import Foundation

struct Card: Codable, CustomStringConvertible {
    let suit: Suit
    let rank: Rank
    
    // Added for testing purposes
    var description: String {
        switch rank {
        case .ace, .jack, .queen, .king: return "\(rank)_of_\(suit)"
        default: return "\(rank.rawValue)_of_\(suit)"
        }
    }
    
    var value: Int {
        switch rank {
        case .jack, .queen, .king: return 10
        default: return rank.rawValue
        }
    }
}
