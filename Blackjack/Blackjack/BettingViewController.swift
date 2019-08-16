//
//  BettingViewController.swift
//  Blackjack
//
//  Created by Drew Bowman on 4/26/19.
//  Copyright © 2019 Drew Bowman. All rights reserved.
//

import UIKit

class BettingViewController: UIViewController {
    
    var game: BlackjackModel!
    
    let myPalette = ColorPalette()
    
    
    @IBOutlet weak var placeBetsLabel: UILabel!
    
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var omniscienceSwitch: UISwitch!
    @IBOutlet weak var omniscienceLabel: UILabel!
    @IBOutlet weak var omniscientStackView: UIStackView!
    @IBOutlet weak var chanceBlackjackLabel: UILabel!
    @IBOutlet weak var recommendationLabel: UILabel!
    
    @IBOutlet var betButtons: [UIButton]!
    @IBOutlet weak var casinoSettingsButton: UIButton!
    @IBOutlet weak var dealButton: UIButton!
    
    let betValues = [5, 25, 100, 500]
    var betButtonDict: [UIButton: Int] = [:]
    
    let gameSaveKey = "game"

    // Set status bar text to white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<betButtons.count {
            let value = betValues[i / 2] * Int(pow(Double(-1),Double(i)))
            betButtonDict[betButtons[i]] = value
        }
        
        // Load saved Blackjack Model
        if let encodedData = UserDefaults.standard.data(forKey: gameSaveKey) {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode(BlackjackModel.self, from: encodedData) {
                game = decodedData
                print("Saved game loaded!")
            } else {
                // This only happens after BlackjackModel has been changed. The previous saved model can't be loaded into a model with new variables/features.
                print("Couldn't load data")
                game = BlackjackModel()
            }
        } else {
            print("There was no data to load. Creating new game.")
            game = BlackjackModel()
        }
        
        omniscienceSwitch.isOn = game.omniscient
        
        addThemeColorsToUI()
        
        updateUISave()
    }
    
    func saveGame() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(game) {
            UserDefaults.standard.set(encodedData, forKey: gameSaveKey)
            print("Game saved")
        } else {
            print("Game could not be saved")
        }
    }
    
    func addThemeColorsToUI() {
        view.backgroundColor = myPalette.background
        
        placeBetsLabel.textColor = .white
        moneyLabel.textColor = .white
        betLabel.textColor = .white
        omniscienceLabel.textColor = .white
        chanceBlackjackLabel.textColor = .white
        casinoSettingsButton.setTitleColor(myPalette.blue, for: .normal)
        dealButton.setTitleColor(myPalette.blue, for: .normal)
    }
    
    func updateUISave() {
        moneyLabel.text = String(format: "Money: $%.2f", game.money)

        betLabel.text = String(format: "Bet: $%.2f", Double(game.bet))
        enableDisableBetButtons()
        showOmniscience(shouldShow: game.omniscient)
        
        if game.bet < 5 {
            dealButton.isEnabled = false
            dealButton.setTitleColor(.lightGray, for: .normal)
        } else {
            dealButton.isEnabled = true
            dealButton.setTitleColor(myPalette.blue, for: .normal)

        }
        
        // Every time the UI is updated (something changed), save the model
        saveGame()
    }
    
    func enableDisableBetButtons() {
        for button in betButtonDict.keys {
            let possibleBet = Double(game.bet + betButtonDict[button]!)
            if possibleBet > game.money || possibleBet < 0 {
                button.isEnabled = false
                button.setTitleColor(.lightGray, for: .normal)
            } else {
                button.isEnabled = true
                if betButtonDict[button]! > 0 {
                    button.setTitleColor(myPalette.brightGreen, for: .normal)
                } else {
                    button.setTitleColor(myPalette.red, for: .normal)
                }
            }
        }
    }
    
    func calculateOmniscience() {
        let goodHandProb = game.getGoodHandProbability()
        chanceBlackjackLabel.text = "Chance of Dealing 18-21: \((10 * goodHandProb).rounded() / 10)%"
        if goodHandProb > 35 {
            recommendationLabel.text = "Recommendation: Bet High"
            recommendationLabel.textColor = myPalette.brightGreen
        } else if goodHandProb > 20 {
            recommendationLabel.text = "Recommendation: Bet Medium"
            recommendationLabel.textColor = myPalette.yellow
        } else {
            recommendationLabel.text = "Recommendation: Bet Low"
            recommendationLabel.textColor = myPalette.red
        }
    }
    
    func showOmniscience(shouldShow: Bool) {
        if shouldShow {
            calculateOmniscience()
            chanceBlackjackLabel.textColor = .white
        } else {
            chanceBlackjackLabel.textColor = myPalette.background
            recommendationLabel.textColor = myPalette.background
        }

    }
    
    @IBAction func omniscienceToggled(_ sender: UISwitch) {
        game.omniscient = sender.isOn
        updateUISave()
    }
    
    @IBAction func betChanged(_ sender: UIButton) {
        let value = betButtonDict[sender]!
        game.changeBet(by: value)
        updateUISave()
    }
    
    // This function prepares for the segue by sending necessary data to other view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Sending data to different view...\n")
        if segue.destination is SettingsViewController {
            let destination = segue.destination as! SettingsViewController
            destination.game = game
        } else if segue.destination is PlayScreenViewController {
            let destination = segue.destination as! PlayScreenViewController
            destination.game = game
        }
    }
    
    // This function allows program to unwind from segue (return from other screen)
    @IBAction func unwindToBetScreen(segue: UIStoryboardSegue) {
        print("\nReturned to BettingView!")
        if segue.source is SettingsViewController {
            let destination = segue.source as! SettingsViewController
            game = destination.game!
        } else if segue.source is PlayScreenViewController {
            let destination = segue.source as! PlayScreenViewController
            game = destination.game!
        }

        updateUISave()
    }

}
