//
//  PlayScreenViewController.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/11/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import UIKit

class PlayScreenViewController: UIViewController {
    

    var game: BlackjackModel!
    
    let myPalette = ColorPalette()
    
    var timer = Timer()

    @IBOutlet var dealerCardsImages: [UIImageView]!
    @IBOutlet weak var dealerScoreLabel: UILabel!
    
    @IBOutlet weak var remainingCardsLabel: UILabel!

    @IBOutlet var remainingCardsText: [UILabel]!
    @IBOutlet weak var aceCountLabel: UILabel!
    @IBOutlet weak var twoCountLabel: UILabel!
    @IBOutlet weak var threeCountLabel: UILabel!
    @IBOutlet weak var fourCountLabel: UILabel!
    @IBOutlet weak var fiveCountLabel: UILabel!
    @IBOutlet weak var sixCountLabel: UILabel!
    @IBOutlet weak var sevenCountLabel: UILabel!
    @IBOutlet weak var eightCountLabel: UILabel!
    @IBOutlet weak var nineCountLabel: UILabel!
    @IBOutlet weak var tensCountLabel: UILabel!
    
    
    @IBOutlet var playerCardsImages: [UIImageView]!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var playerOmniStackView: UIStackView!
    @IBOutlet weak var chanceBustingLabel: UILabel!
    @IBOutlet weak var playRecommendationLabel: UILabel!
    
    
    @IBOutlet var allText: [UILabel]!
    
    @IBOutlet weak var standButton: UIButton!
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var doubleButton: UIButton!
    @IBOutlet weak var surrenderButton: UIButton!
    @IBOutlet weak var insuranceButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    
    @IBOutlet weak var outcomeMessageLabel: UILabel!
    
    
    // Set status bar text to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PlayView Loaded!")

        addThemeColorsToUI()
        
        for card in playerCardsImages + dealerCardsImages {
            card.isHidden = true
        }
        
        game.beginRound()
        updateUI()
        hideOmniscience(shouldHide: !game.omniscient)
        
        if game.playerHand.hasBlackjack {
            giveDealerCard()
            endRound()
        }


    }
    
    func hideOmniscience(shouldHide: Bool) {
        if shouldHide {
            dealerScoreLabel.text = "Dealer Score: ???"
            for text in remainingCardsText {
                text.textColor = myPalette.background
            }
            remainingCardsLabel.textColor = myPalette.background
            chanceBustingLabel.textColor = myPalette.background
            playRecommendationLabel.textColor = myPalette.background
        }
    }
    
    func performOmniscientFunctions() {
        // Find dealer's likely score
        dealerScoreLabel.text = "Dealer's Likely Score: \(game.getLikelyDealerScore())"
        
        // Fill in remaining card values table
        aceCountLabel.text = "\(game.remainingCardValues["A"]!)"
        twoCountLabel.text = "\(game.remainingCardValues["2"]!)"
        threeCountLabel.text = "\(game.remainingCardValues["3"]!)"
        fourCountLabel.text = "\(game.remainingCardValues["4"]!)"
        fiveCountLabel.text = "\(game.remainingCardValues["5"]!)"
        sixCountLabel.text = "\(game.remainingCardValues["6"]!)"
        sevenCountLabel.text = "\(game.remainingCardValues["7"]!)"
        eightCountLabel.text = "\(game.remainingCardValues["8"]!)"
        nineCountLabel.text = "\(game.remainingCardValues["9"]!)"
        tensCountLabel.text = "\(game.remainingCardValues["10-K"]!)"
        
        // Find chance of busting
        chanceBustingLabel.text = "Chance of Busting: \(Int(game.getChanceOfBusting()))%"
        
        // Get best move recommendation
        var recommendationString = "Recommendation: "
        switch game.getBestPlay() {
        case .double: recommendationString += "Double"
        case .hit: recommendationString += "Hit"
        case .insurance: recommendationString += "Purchase Insurance"
        case .stand: recommendationString += "Stand"
        case .surrender: recommendationString += "Surrender"
        }
        playRecommendationLabel.text = recommendationString
    }
    
    func updateUI() {
        // Show dealer cards
        for i in 0..<game.dealerHand.cards.count {
            dealerCardsImages[i].image = UIImage(named: game.dealerHand.cards[i].description)
            dealerCardsImages[i].isHidden = false
        }
        
        // Show card back in second slot if dealer only has one card
        if game.dealerHand.cards.count < 2 {
            dealerCardsImages[1].image = UIImage(named: "back.png")
            dealerCardsImages[1].isHidden = false
        }
        
        // Show player cards
        for i in 0..<game.playerHand.cards.count {
            playerCardsImages[i].image = UIImage(named: game.playerHand.cards[i].description)
            playerCardsImages[i].isHidden = false
        }
        
        // Show player score
        playerScoreLabel.text = "Player Score: \(game.playerHand.valueDescription)"
        
        // Make sure player buttons are enabled/disabled correctly
        game.checkActionsUserCanTake()
        enableDisableButtons()
        
        if game.omniscient {
            performOmniscientFunctions()
        }
        
        // Make sure outcome message is hidden (done to hide label one action after purchasing insurance)
        outcomeMessageLabel.textColor = myPalette.background
    }
    
    func addThemeColorsToUI() {
        view.backgroundColor = myPalette.background

        for text in allText {
            text.textColor = .white
        }
        
        standButton.setTitleColor(myPalette.blue, for: .normal)
        hitButton.setTitleColor(myPalette.blue, for: .normal)
        doubleButton.setTitleColor(myPalette.blue, for: .normal)
        surrenderButton.setTitleColor(myPalette.blue, for: .normal)
        insuranceButton.setTitleColor(myPalette.blue, for: .normal)
        playAgainButton.setTitleColor(myPalette.blue, for: .normal)

        outcomeMessageLabel.textColor = myPalette.brightGreen
    }
    
    func enableDisableButtons() {
        // Disable buttons for actions that are no longer possible
        if !game.canDouble {
            doubleButton.isEnabled = false
            doubleButton.setTitleColor(.lightGray, for: .normal)
        }
        
        if !game.canSurrender {
            surrenderButton.isEnabled = false
            surrenderButton.setTitleColor(.lightGray, for: .normal)
        }
        
        if !game.canBuyInsurance {
            insuranceButton.isEnabled = false
            insuranceButton.setTitleColor(.lightGray, for: .normal)
        }

    }
    
    func hideButtonsAndPlayerOmni() {
        standButton.isHidden = true
        hitButton.isHidden = true
        doubleButton.isHidden = true
        surrenderButton.isHidden = true
        insuranceButton.isHidden = true
        chanceBustingLabel.textColor = myPalette.background
        playRecommendationLabel.textColor = myPalette.background
    }

    @IBAction func standTapped(_ sender: UIButton) {        
        // Immediately give dealer a card
        giveDealerCard()
        
        // Create timer that will continue to give cards to dealer if necessary
        if game.dealerHand.finalValue < game.currentSettings.dealerStandsAt {
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(giveDealerCard), userInfo: nil, repeats: true)
        }
    }
    
    @objc func giveDealerCard() {
        hideButtonsAndPlayerOmni()

        game.dealToDealer()
        updateUI()
        dealerScoreLabel.text = "Dealer's Score: \(game.dealerHand.valueDescription)"
        if game.dealerHand.finalValue >= game.currentSettings.dealerStandsAt {
            timer.invalidate()
            endRound()
        }

        
    }
    
    func endRound() {
        // Compare hands
        let result = game.compareHands()
        
        // Payout as necessary
        let payout = game.payout(comparisonResult: result)
        
        // Generate outcome message
        outcomeMessageLabel.text = game.getResultMessage(comparisonResult: result, payout: payout)
        
        // Set color of outcome message so player can quickly tell if they won/tied/lost
        if payout > 0 {
            outcomeMessageLabel.textColor = myPalette.brightGreen
        } else if payout < 0 {
            outcomeMessageLabel.textColor = myPalette.red
        } else {
            outcomeMessageLabel.textColor = myPalette.yellow
        }
        
        // Show play again button
        playAgainButton.isHidden = false
    }
    
    @IBAction func hitTapped(_ sender: UIButton) {
        game.dealToPlayer()
        updateUI()
        
        // See if round is over
        if game.playerHand.hasBust || game.playerHand.cards.count == game.currentSettings.numCardCharlie{
            giveDealerCard()
            endRound()
        }
    }
    
    @IBAction func doubleTapped(_ sender: UIButton) {
        game.playerHasDoubled = true
        game.dealToPlayer()
        
        giveDealerCard()
        
        if game.dealerHand.finalValue < game.currentSettings.dealerStandsAt {
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(giveDealerCard), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func surrenderTapped(_ sender: UIButton) {
        game.playerHasSurrendered = true
        giveDealerCard()
        endRound()
    }
    
    
    
    @IBAction func insuranceTapped(_ sender: UIButton) {
        let message = game.purchaseInsurance()
        updateUI()
        outcomeMessageLabel.text = message
        outcomeMessageLabel.textColor = myPalette.red
    }
    
    @IBAction func playAgainTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "playToBetScreen", sender: self)
    }
    
}
