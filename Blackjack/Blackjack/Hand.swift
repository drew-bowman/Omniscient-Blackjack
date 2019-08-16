//
//  Hand.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/26/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import Foundation

struct Hand: Codable {
    var cards: [Card] = []
    var hasAce: Bool {
        for card in cards {
            if card.rank == .ace {
                return true
            }
        }
        return false
    }
    
    var softValue: Int {
        var sum = 0
        for card in cards {
            sum += card.value
        }
        return sum
    }
    
    var hardValue: Int {
        var sum = softValue
        if hasAce {
            sum += 10
        }
        return sum
    }
    
    var finalValue: Int {
        if hardValue > 21 {
            return softValue
        } else {
            return hardValue
        }
    }
    
    var valueDescription: String {
        if hardValue == softValue {
            return "\(hardValue)"
        } else if hardValue <= 21{
            return "\(softValue) / \(hardValue)"
        } else {
            return "\(softValue)"
        }
    }
    
    var hasBlackjack: Bool {
        if cards.count == 2 && hardValue == 21 {
            return true
        } else {
            return false
        }
    }
    
    var hasBust: Bool {
        if softValue > 21 {
            return true
        } else {
            return false
        }
    }
}
