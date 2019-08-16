//
//  CasinoSettings.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/26/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import Foundation

struct CasinoSettings: Codable {
    var decksInPlay = 2
    var blackjackPayoutRate = 1.5
    var numCardCharlie = 5
    var charliePayoutRate = 1.25
    var insurancePriceRate = 0.5
    var insurancePayoutRate = 2.0
    var dealerStandsAt = 17
}
