//
//  BlackjackModel.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/26/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import Foundation

struct BlackjackModel: Codable {
    var deck: [Card] = []
    var dealerHand = Hand()
    var playerHand = Hand()
    var money: Double = 100
    var bet: Int = 5
    var playerHasInsurance = false
    var playerHasDoubled = false
    var playerHasSurrendered = false
    var canDouble = true
    var canSurrender = true
    var canBuyInsurance = true
    var omniscient = true
    var currentSettings = CasinoSettings()
    
    var remainingCardValues: [String:Int] {
        var cardValueDictionary = ["A": 0, "2": 0, "3": 0, "4": 0, "5": 0, "6": 0, "7": 0, "8":0, "9": 0, "10-K": 0]
        
        for card in deck {
            if card.value == 1 {
                cardValueDictionary["A"]! += 1
            } else if card.value == 10 {
                cardValueDictionary["10-K"]! += 1
            } else {
                cardValueDictionary["\(card.value)"]! += 1
            }
        }
        return cardValueDictionary
    }
    
    init() {
        shuffleDeck()
    }
    
    mutating func shuffleDeck() {
        deck = []
        for rank in Rank.allCases {
            for suit in Suit.allCases {
                for _ in 0..<currentSettings.decksInPlay {
                    deck.append(Card(suit: suit, rank: rank))
                }
            }
        }
        deck.shuffle()
    }
    
    mutating func changeBet(by amount: Int) {
        bet += amount
    }
    
    mutating func dealToPlayer() {
        playerHand.cards.append(deck.popLast()!)
        
        if deck.count == 0 {
            shuffleDeck()
        }
    }
    
    mutating func dealToDealer() {
        dealerHand.cards.append(deck.popLast()!)
        
        if deck.count == 0 {
            shuffleDeck()
        }
    }
    
    mutating func checkActionsUserCanTake() {
        // Double
        if bet * 2 > Int(money) {
            canDouble = false
        }
        
        // Insurance
        if dealerHand.cards.count > 0 {
            if dealerHand.cards[0].rank != .ace || playerHasInsurance {
                canBuyInsurance = false
            }
        }
        
        // Double, Insurance, Surrender
        if playerHand.cards.count > 2 {
            canDouble = false
            canSurrender = false
            canBuyInsurance = false
        }
    }

    mutating func purchaseInsurance() -> String {
        // Give player insurance
        playerHasInsurance = true
        let price = Double(bet) * currentSettings.insurancePriceRate
        money -= price
        
        // Alert the player that they bought insurance
        return String(format: "Bought Insurance. - $%.2f", price)
    }
    
    // Prepare game for new round
    mutating func beginRound() {
        // Empty hands
        dealerHand.cards = []
        playerHand.cards = []
        
        // Reset insurance, double, surrender
        playerHasInsurance = false
        playerHasDoubled = false
        playerHasSurrendered = false
        
        // Reset actions player can take
        canDouble = true
        canSurrender = true
        canBuyInsurance = true
        
        // Deal 2 cards to player, 1 to dealer
        dealToPlayer()
        dealToPlayer()
        dealToDealer()
    }
    
    func compareHands() -> (HandType, Outcome) {
        if playerHasSurrendered {
            return (.surrender, .lose) // Player surrendered
        } else if playerHand.hasBust {
            return (.bust, .lose) // Player bust
        } else if dealerHand.hasBlackjack {
            if playerHasInsurance {
                return (.insurancePayout, .win) // Insurance payout
            } else if playerHand.hasBlackjack {
                return (.blackjack, .push) // Blackjack tie
            } else {
                return (.blackjack, .lose) // Dealer won with blackjack
            }
        } else if playerHand.hasBlackjack {
            return (.blackjack, .win) // Player won with blackjack
        } else if playerHand.cards.count == currentSettings.numCardCharlie {
            return (.charlie, .win) // Player had charlie
        } else if dealerHand.hasBust {
            return (.bust, .win) // Dealer bust
        } else if playerHand.finalValue == dealerHand.finalValue {
            return (.regular, .push) // Both have same value
        } else if playerHand.finalValue > dealerHand.finalValue {
            return (.regular, .win) // Player has higher value
        }
        return (.regular, .lose) // If none of the above, player lost
    }
    
    mutating func payout(comparisonResult: (HandType, Outcome)) -> Double {
        var payoutValue = 0.0
        
        let hand = comparisonResult.0
        let outcome = comparisonResult.1
        
        switch outcome {
        case .lose:
            switch hand {
            case .surrender: payoutValue = -Double(bet) * 0.5
            default: payoutValue = Double(-bet) // All other cases, player loses entire bet
            }
        case .push: payoutValue = 0 // Player doesn't win/lose anything
        case .win:
            switch hand {
            case .blackjack: payoutValue = Double(bet) * currentSettings.blackjackPayoutRate
            case .charlie: payoutValue = Double(bet) * currentSettings.charliePayoutRate
            case .insurancePayout: payoutValue = Double(bet) * currentSettings.insurancePayoutRate
            case .bust, .regular: payoutValue = Double(bet)
            case .surrender: payoutValue = 0 // This line should never be run but is required to complete switch statement
            }
        }
        
        if playerHasDoubled {
            payoutValue *= 2
        }
        
        money += payoutValue
        
        getValidMoneyBet()
        
        return payoutValue
    }
    
    mutating func getValidMoneyBet() {
        // Ensure money doesn't get below 5
        if money < 5 {
            money = 5
        }
        
        // Make sure bet isn't greater than money
        if bet > Int(money) {
            bet = (Int(money) / 5) * 5 // Make sure bet is a multiple of 5
        }
    }
    
    func getResultMessage(comparisonResult: (HandType, Outcome), payout: Double) -> String {
        let hand = comparisonResult.0
        let outcome = comparisonResult.1
        var payout = payout
        
        var resultMessage = ""
        
        switch hand {
        case .blackjack:
            switch outcome {
            case .lose: resultMessage = "Dealer Blackjack."
            case .push: resultMessage = "Blackjack Tie."
            case .win: resultMessage = "Blackjack!"
            }
        case .bust:
            switch outcome {
            case .lose: resultMessage = "You Busted."
            case .push: resultMessage = "ERR." // This should never happen
            case .win: resultMessage = "Dealer Busted!"
            }
        case .charlie: resultMessage = "Charlie!" // Only player can get charlie
        case .insurancePayout: resultMessage = "Insurance!" // since you can only win with insurance, don't need nested switch
        case .regular:
            switch outcome {
            case .lose: resultMessage = "Dealer Wins."
            case .push: resultMessage = "Equal Hands."
            case .win: resultMessage = "You Win!"
            }
        case .surrender: resultMessage = "Surrendered." // since you only ever lose with surrender, don't need nested switch
        }
        
        if payout < 0 {
            resultMessage += " - "
            payout = abs(payout)
        } else {
            resultMessage += " + "
        }
        
        resultMessage += String(format: "$%.2f", payout)
        
        return resultMessage
    }
    
    // Typically, 18-21 is considered a good hand
    func getGoodHandProbability() -> Float {
        let aces = remainingCardValues["A"]!
        let tenValues = remainingCardValues["10-K"]!
        let nines = remainingCardValues["9"]!
        let eights = remainingCardValues["8"]!
        let sevens = remainingCardValues["7"]!
        
        // A+10
        let numWaysToGet21 = aces * tenValues
        
        // A+9, 10+10
        let numWaysToGet20 = aces * nines + (tenValues * (tenValues - 1) / 2)
        
        // A+8, 10+9
        let numWaysToGet19 = aces * eights + tenValues * nines
        
        // A+7, 10+8, 9+9
        let numWaysToGet18 = aces * sevens + tenValues * eights + (nines * (nines - 1) / 2)
        
        let numGoodHands = numWaysToGet21 + numWaysToGet20 + numWaysToGet19 + numWaysToGet18
        let totalPossibleHands = deck.count * (deck.count-1) / 2
        
        var probabilityOfGoodHand = 100 * Float(numGoodHands) / Float(totalPossibleHands)
        
        if probabilityOfGoodHand.isNaN { // Occurs when there are zero possible hands (only one card left in the deck)
            probabilityOfGoodHand = 0
        }
        
        return probabilityOfGoodHand
    }
    
    func getChanceOfBusting() -> Double {
        let amountTilBust = 21 - playerHand.softValue
        var numCardsThatWouldBust = 0
        
        if amountTilBust < 10 {
            numCardsThatWouldBust += remainingCardValues["10-K"]!
        }
        if amountTilBust < 9 {
            numCardsThatWouldBust += remainingCardValues["9"]!
        }
        if amountTilBust < 8 {
            numCardsThatWouldBust += remainingCardValues["8"]!
        }
        if amountTilBust < 7 {
            numCardsThatWouldBust += remainingCardValues["7"]!
        }
        if amountTilBust < 6 {
            numCardsThatWouldBust += remainingCardValues["6"]!
        }
        if amountTilBust < 5 {
            numCardsThatWouldBust += remainingCardValues["5"]!
        }
        if amountTilBust < 4 {
            numCardsThatWouldBust += remainingCardValues["4"]!
        }
        if amountTilBust < 3 {
            numCardsThatWouldBust += remainingCardValues["3"]!
        }
        if amountTilBust < 2 {
            numCardsThatWouldBust += remainingCardValues["2"]!
        }
        if amountTilBust < 1 {
            numCardsThatWouldBust += remainingCardValues["A"]!
        }
        
        return Double(100 * numCardsThatWouldBust / deck.count)
    }
    
    func getLikelyDealerScore() -> Double {
        var totalScores = 0
        for card in deck {
            let potentialHand = Hand(cards: [dealerHand.cards[0], card])
            totalScores += potentialHand.hardValue
        }
        let totalHands = deck.count
        let likelyScore = Double(totalScores) / Double(totalHands)
        return round(likelyScore * 10) / 10
    }
    
    func getBestPlay() -> Play {
        // These recommendations were adapted from: https://www.blackjackapprenticeship.com/blackjack-strategy-charts/
        
        // Apparently you should never buy insurance. Never check for it / recommend it.
        
        var bestMove: Play = .insurance // Done for testing purposes, since bestMove should never equal insurance
        
        let dealerShowing = dealerHand.finalValue
        
        if playerHand.hasAce && playerHand.softValue <= 12 { // Soft hand route
            if playerHand.finalValue >= 20 { // Soft 20+
                bestMove = .stand
            } else if playerHand.finalValue == 19 { // Soft 19
                if dealerShowing == 6 {
                    bestMove = .double
                } else {
                    bestMove = .stand
                }
            } else if playerHand.finalValue == 18 { // Soft 18
                if 2...6 ~= dealerShowing {
                    bestMove = .double
                } else if 7...8 ~= dealerShowing {
                    bestMove = .stand
                } else {
                    bestMove = .hit
                }
            } else if playerHand.finalValue == 17 { // Soft 17
                if 3...6 ~= dealerShowing {
                    bestMove = .double
                } else {
                    bestMove = .hit
                }
            } else if 15...16 ~= playerHand.finalValue { // Soft 15-16
                if 4...6 ~= dealerShowing {
                    bestMove = .double
                } else {
                    bestMove = .hit
                }
            } else if 13...14 ~= playerHand.finalValue { // Soft 13-14
                if 5...6 ~= dealerShowing {
                    bestMove = .double
                } else {
                    bestMove = .hit
                }
            }
            else if playerHand.finalValue == 12 { // Soft 12
                bestMove = .hit
            }
        } else { // Hard hand route
            if playerHand.finalValue >= 17 { // Hard 17+
                bestMove = .stand
            } else if 13...16 ~= playerHand.finalValue { // Hard 13-14
                if playerHand.finalValue == 16 && dealerShowing >= 9 || playerHand.finalValue == 15 && dealerShowing == 10 {
                    bestMove = .surrender
                } else if 2...6 ~= dealerShowing {
                    bestMove = .stand
                } else {
                    bestMove = .hit
                }
            } else if playerHand.finalValue == 12 { // Hard 12
                if 4...6 ~= dealerShowing {
                    bestMove = .stand
                } else {
                    bestMove = .hit
                }
            } else if 10...11 ~= playerHand.finalValue { // Hard 10-11
                bestMove = .double
            } else if playerHand.finalValue == 9 { // Hard 9
                if 3...6 ~= dealerShowing {
                    bestMove = .double
                } else {
                    bestMove = .hit
                }
            } else {
                bestMove = .hit
            }
        }
        
        // Given bestMove, make sure player can actually make that move
        if bestMove == .double && !canDouble {
            bestMove = .hit
        }
        
        if bestMove == .surrender && !canSurrender {
            bestMove = .stand
        }
        
        return bestMove
        
    }
    
    
}
