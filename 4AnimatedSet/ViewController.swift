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

    private var initialDispense = 12
    lazy var animator = UIDynamicAnimator(referenceView: cardsArea)
    lazy var cardBehavior = CardBehavior(in: animator)
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    
    @IBOutlet weak var cardsArea: CardsAreaView!  {
        didSet {
            let tap = UITapGestureRecognizer(target: self,
                                             action: #selector(touchCard(byHandlingGestureRecognizedBy:)))
            cardsArea.addGestureRecognizer(tap)
        }
    }
        
    var cardToGoDiscard : CardView = CardView()
    
    @objc func touchCard(byHandlingGestureRecognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            if let card = cardsArea.getCardAtHitPoint(recognizer.location(in: cardsArea)) {
                cardTouched(card)
            } else if cardsArea.isDealPileClicked(recognizer.location(in: cardsArea)) {
                let previousSize = cardsArea.gridSize
                UIView.transition(with: cardsArea, duration: 0.4, options: [.layoutSubviews, .curveEaseIn, .transitionCrossDissolve, .showHideTransitionViews] , animations: {
                    self.cardsArea.gridSize += 3
                }, completion: {completion in
                    self.putCardsOnTable(numberOfCards: 3, startingIndex: previousSize)
                })
            }
        default: break
        }
    }
    
    private func cardTouched(_ card: Card) {
        //1. Before selection, recover from the previous state: 3 unmatched cards
        if (game.ThreeCardSelected) {
            for card in game.chosenCards {
                cardsArea.setCardDisplayState(card, displayState: .onDisplay)
            }
            game.deselectAll()
        }
        
        //2. Find out if we should chose one more card, or deselect a card
        if (game.isTheCardSelected(card)) {
            game.deselectCard(card)
            cardsArea.setCardDisplayState(card, displayState: .onDisplay)
        }
        else {
            game.selectCard(card)
            if (!game.ThreeCardSelected) {
                cardsArea.setCardDisplayState(card, displayState: .chosen)
            }
        }
        //3. Make decision
        if (game.ThreeCardSelected) {
            //Can't choose more becuase we have 3 already, so replace/deslect the chosen one and add new choice
            let (isSet, cards) = game.tryGetSelectedAsASet()
            
            if (!isSet) {
                for card in cards {
                    cardsArea.setCardDisplayState(card, displayState: .mismatched)
                }
            } else {
                game.recyleAllSelectedCards()
                let backText = game.setMatchedString
                for card in cards {
                    if let cv = cardsArea.cardView(card) {
                        cardsArea.setCardDisplayState(card, displayState: .matched)
                        
                        // Dispense Another card to the flyway card
                        if let index = cardsArea.cardView(card)?.gridIndex {
                            replaceCard(at: index)
                        }
                        // End of it
                        
                        cardsArea.bringSubviewToFront(cv)    //So that it doesn't fly behind other cards
                        cardBehavior.addItem(cv)
                        
                        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { timer in
                            self.cardBehavior.removeItem(cv)
                            cv.displayState = .onDisplay
                            
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.6,
                                delay: 0,
                                options: .beginFromCurrentState,
                                animations: {
                                    cv.frame = self.cardsArea.discardPile.frame
                            },
                                completion: { position in
                                    UIView.transition(
                                        with: cv,
                                        duration: 0.5,
                                        options: [.transitionFlipFromLeft],
                                        animations: {
                                            cv.displayState = .faceDown
                                    },
                                        completion: { finished in
                                            cv.removeFromSuperview()
                                            self.cardsArea.discardPile.backText = backText
                                    })
                            })
                        }
                    }
                }
            }
            giveScore(isSet)
        }

    }
    
    @IBAction func newGame(_ sender: UIButton) {
        game = SetGame()
        cardsArea.removeAll()
        cardsArea.gridSize = cardsArea.minGridSize
        cardsArea.addPiles()
        putCardsOnTable(numberOfCards: initialDispense)
        
        //TODO: Deal stack default style
        game.scaledScore = 0
        scoreLabel.text = "Score: \(String(format: "%.1f", game.scaledScore))"
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newGameButton.layer.cornerRadius = 5.0
        // TODO: Initial putCardsOnTable(numberOfCards: initialDispense)
        cardsArea.gridSize = initialDispense
        cardsArea.addPiles()
        putCardsOnTable(numberOfCards: initialDispense)
    }
    
    private func putCardsOnTable(numberOfCards number: Int, startingIndex: Int = 0) {
        for index in 0 ..< number
        {
            if let newCard = game.drawNextCardForDisplay() {
                Timer.scheduledTimer(withTimeInterval: 0.4 * Double(index), repeats: false) { timer in
                    self.cardsArea.addCard(newCard, gridIndex: index + startingIndex)
                }
            }
            else {
                cardsArea.dealPile.removeFromSuperview()
            }
        }
        
        if !game.hasMoreCardsInDeck {
            cardsArea.dealPile.removeFromSuperview()
        }
    }
    
    private func replaceCard(at index: Int) {
        if let newCard = game.drawNextCardForDisplay() {
            cardsArea.addCard(newCard, gridIndex: index)
        } else {
            if cardsArea.subviews.contains(cardsArea.dealPile) {
                cardsArea.dealPile.removeFromSuperview()
            }
            
            cardsArea.moveupCards(from: index)
        }
    }
    
    private func giveScore(_ isSet: Bool) {
        //Now we either have a set or not have a set, or we don't have enough
        if (isSet) {
            game.scaledScore += 3/game.scale
        }
        else {
            game.scaledScore -= 5 / game.scale
        }
        scoreLabel.text = "Score: \(String(format: "%.1f", game.scaledScore))"
    }
  
}

