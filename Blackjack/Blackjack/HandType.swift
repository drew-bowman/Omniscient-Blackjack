//
//  HandType.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/26/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import Foundation

enum HandType: String, Codable {
    case blackjack
    case insurancePayout
    case charlie
    case bust
    case regular
    case surrender
}
