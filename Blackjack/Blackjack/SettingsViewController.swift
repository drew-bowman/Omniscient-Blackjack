//
//  SettingsViewController.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/11/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var game: BlackjackModel!
    
    let myPalette = ColorPalette()

    @IBOutlet weak var decksLabel: UILabel!
    @IBOutlet weak var decksStepper: UIStepper!
    
    @IBOutlet weak var blackjackPayoutLabel: UILabel!
    @IBOutlet weak var blackjackStepper: UIStepper!
    
    @IBOutlet weak var xCardCharlieLabel: UILabel!
    @IBOutlet weak var xCardCharlieStepper: UIStepper!
    
    @IBOutlet weak var charliePayoutLabel: UILabel!
    @IBOutlet weak var charliePayoutStepper: UIStepper!
    
    @IBOutlet weak var insurancePriceLabel: UILabel!
    @IBOutlet weak var insurancePriceStepper: UIStepper!
    
    @IBOutlet weak var insurancePayoutLabel: UILabel!
    @IBOutlet weak var insurancePayoutStepper: UIStepper!
    
    @IBOutlet weak var dealerStandsAtLabel: UILabel!
    @IBOutlet weak var dealerStandsAtStepper: UIStepper!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet var allExplanations: [UILabel]!

    
    @IBOutlet var allOtherText: [UILabel]!
    
    
    @IBOutlet var allSteppers: [UIStepper]!

    // Set status bar text to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        updateUI()
        
        addThemeColorsToUI()
    }
    
    func addThemeColorsToUI() {
        view.backgroundColor = myPalette.background
        
        for text in allOtherText {
            text.textColor = .white
        }
        for text in allExplanations {
            text.textColor = myPalette.lightestGray
        }
        for stepper in allSteppers {
            stepper.tintColor = myPalette.blue
        }
        saveButton.setTitleColor(myPalette.blue, for: .normal)
    }
    
    func loadSettings() {
        decksStepper.value = Double(game.currentSettings.decksInPlay)
        blackjackStepper.value = game.currentSettings.blackjackPayoutRate
        xCardCharlieStepper.value = Double(game.currentSettings.numCardCharlie)
        charliePayoutStepper.value = game.currentSettings.charliePayoutRate
        insurancePriceStepper.value = game.currentSettings.insurancePriceRate
        insurancePayoutStepper.value = game.currentSettings.insurancePayoutRate
        dealerStandsAtStepper.value = Double(game.currentSettings.dealerStandsAt)
        print("Settings Loaded!")
    }
    
    func updateUI() {
        decksLabel.text = "Decks: \(Int(decksStepper.value))"
        blackjackPayoutLabel.text = "Payout Rate: \(blackjackStepper.value)"
        xCardCharlieLabel.text = "\(Int(xCardCharlieStepper.value))-Card Charlie"
        charliePayoutLabel.text = "Payout Rate: \(charliePayoutStepper.value)"
        insurancePriceLabel.text = "Price: \(insurancePriceStepper.value)"
        insurancePayoutLabel.text = "Payout Rate: \(insurancePayoutStepper.value)"
        dealerStandsAtLabel.text = "Dealer Stands at: \(Int(dealerStandsAtStepper.value))"
    }
    

    @IBAction func decksChanged(_ sender: UIStepper) {
        game.currentSettings.decksInPlay = Int(sender.value)
        game.shuffleDeck()
        updateUI()
    }
    
    @IBAction func blackjackRateChanged(_ sender: UIStepper) {
        game.currentSettings.blackjackPayoutRate = sender.value
        updateUI()
    }
    
    @IBAction func numCardCharlieChanged(_ sender: UIStepper) {
        game.currentSettings.numCardCharlie = Int(sender.value)
        updateUI()
    }
    @IBAction func charliePayoutRateChanged(_ sender: UIStepper) {
        game.currentSettings.charliePayoutRate = sender.value
        updateUI()
    }
    
    @IBAction func insurancePriceChanged(_ sender: UIStepper) {
        game.currentSettings.insurancePriceRate = sender.value
        updateUI()
    }
    
    
    @IBAction func insurancePayoutRateChanged(_ sender: UIStepper) {
        game.currentSettings.insurancePayoutRate = sender.value
        updateUI()
    }
    
    @IBAction func dealerStandAtChanged(_ sender: UIStepper) {
        game.currentSettings.dealerStandsAt = Int(sender.value)
        updateUI()
    }
    
    
    
    
    
    

    
}


