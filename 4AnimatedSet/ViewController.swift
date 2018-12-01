//
//  ViewController.swift
//  3GraphicalSet
//
//  Created by Chris Wu on 11/14/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var game = SetGame()

    private var deal3MoreButtonBgColor: UIColor? = nil
    private var initialDispense = 12

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deal3MoreButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var suggestButton: UIButton!
    
    @IBOutlet weak var cardsArea: CardsAreaView!  {
        didSet {
            let tap = UITapGestureRecognizer(target: self,
                                             action: #selector(touchCard(byHandlingGestureRecognizedBy:)))
            cardsArea.addGestureRecognizer(tap)
            
            let swipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(swipeAcross))
            swipe.direction = [.left,.right]
            cardsArea.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self,
                                                     action: #selector(shuffle(byHandlingGestureRecognizedBy:)))
            cardsArea.addGestureRecognizer(rotate)
        }
    }
    
    @objc func shuffle(byHandlingGestureRecognizedBy recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            let numberOfCards = game.numberOfCardsOnTable
            game.shuffle()
            cardsArea.removeAll()
            putCardsOnTable(numberOfCards: numberOfCards)
            setShouldSuggest()

        default: break
        }
    }
    
    @objc func swipeAcross(byHandlingGestureRecognizedBy recognizer: UISwipeGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            deal3More(deal3MoreButton)
        default: break
        }
    }
    
    @objc func touchCard(byHandlingGestureRecognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            if let card = cardsArea.getCardAtHitPoint(recognizer.location(in: cardsArea)) {
                //Find out if we should chose one more card, or deselect a card
                if game.canChooseMore {
                    if (game.isTheCardSelected(card)) {
                        game.deselectCard(card)
                        cardsArea.setCardDisplayState(card, displayState: .onDisplay)
                    }
                    else {
                        game.selectCard(card)
                        cardsArea.setCardDisplayState(card, displayState: .chosen)
                    }
                }
                else {
                    //Can't choose more becuase we have 3 already, so replace/deslect the chosen one and add new choice
                    let (isSet, cards) = game.tryGetSelectedAsASet()
                    
                    //Replace, remove or reset
                    for card in cards {
                        if (isSet) {
                            cardsArea.removeCard(card)
                            putCardsOnTable(numberOfCards: 1)
                        }
                        else {
                            cardsArea.setCardDisplayState(card, displayState: .onDisplay)
                        }
                    }
                    
                    if (isSet) {
                        game.recyleAllSelectedCards()
                    }
                    else {
                        game.deselectAll()
                    }
                    
                    //Now we can select again, the card may move after selection because of remove and reOrder
                    game.selectCard(card)
                    cardsArea.setCardDisplayState(card, displayState: .chosen)
                }
                
                //After selection we can give score and adjust state
                giveScore()
            }
            
        default: break
        }
    }
    
    @IBAction func suggestASet(_ sender: UIButton) {
        for card in game.resetAllSelected() {
            cardsArea.setCardDisplayState(card, displayState: .onDisplay)
        }

        if let matchingSet = game.findAMatchSet() {
            for card in matchingSet {
                cardsArea.setCardDisplayState(card, displayState: .suggested)
            }
        }
        else {
            print("All \(game.numberOfCardsOnTable) cards on table don't have a set")
        }
        
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        game = SetGame()
        cardsArea.removeAll()
        putCardsOnTable(numberOfCards: initialDispense)
        
        deal3MoreButton.isEnabled = true
        deal3MoreButton.backgroundColor = deal3MoreButtonBgColor
        game.scaledScore = 0
        scoreLabel.text = "Score: \(String(format: "%.1f", game.scaledScore))"
        
        setShouldSuggest()
    }
    
    @IBAction func deal3More(_ sender: UIButton) {
        let (isSet, cards) = game.tryGetSelectedAsASet()
        
        //Replace, remove or reset
        for card in cards {
            if (isSet) {
                cardsArea.removeCard(card)
                putCardsOnTable(numberOfCards: 1)
            }
            else {
                cardsArea.setCardDisplayState(card, displayState: .onDisplay)
            }
        }
        
        if (isSet) {
            //Selected 3 matched, replaced them with 3 new ones
            game.recyleAllSelectedCards()
        }
        else if cards.count == 3 {
            //Seleced 3 not matched, deselect them and add 3 cards
            game.deselectAll()
            putCardsOnTable(numberOfCards: 3)
        }
        else {
            //Not enough cards selected, just add 3 cards
            putCardsOnTable(numberOfCards: 3)
        }
        
        setShouldSuggest()
    }
    
    override func viewDidLoad() {
        suggestButton.layer.cornerRadius = 5.0
        newGameButton.layer.cornerRadius = 5.0
        deal3MoreButton.layer.cornerRadius = 5.0
        deal3MoreButtonBgColor = deal3MoreButton.backgroundColor
        
        super.viewDidLoad()
        putCardsOnTable(numberOfCards: initialDispense)
        setShouldSuggest()
    }
    
    private func putCardsOnTable(numberOfCards number: Int) {
        for _ in 0 ..< number
        {
            if let newCard = game.drawNextCardForDisplay() {
                cardsArea.addCard(newCard)
            }
            else {
                deal3MoreButton.isEnabled = false
                deal3MoreButton.backgroundColor = UIColor.darkGray
            }
        }
    }
    
    private func setShouldSuggest() {
        let matchSet = game.findAMatchSet()
        if matchSet != nil {
            suggestButton.isEnabled = true
        }
        else {
            suggestButton.isEnabled = false
        }
    }
    
    private func giveScore() {
        //Now we either have a set or not have a set, or we don't have enough
        let (isSet, cards) = game.tryGetSelectedAsASet()
        if (isSet) {
            game.scaledScore += 3/game.scale
        }
        else if cards.count == 3 {
            game.scaledScore -= 5 / game.scale
        }
        scoreLabel.text = "Score: \(String(format: "%.1f", game.scaledScore))"
        
        for card in cards {
            if (isSet) {
                cardsArea.setCardDisplayState(card, displayState: .matched)
            }
            else {
                cardsArea.setCardDisplayState(card, displayState: .mismatched)
            }
        }
    }
  
}

