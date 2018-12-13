//
//  CardsAreaView.swift
//  3GraphicalSet
//
//  Created by Chris Wu on 11/16/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

class CardsAreaView: UIView {
    
    //MARK: Instance variables
    private var cardButtons = [Card: CardView]() { didSet { setNeedsDisplay(); setNeedsLayout() } }
    private(set) var grid = Grid(layout: Grid.Layout.aspectRatio(1.8))
    var gridMaxCellCount: Double {
        return Double(grid.dimensions.rowCount * grid.dimensions.columnCount)
    }
    
    var dealPile = CardView()
    var discardPile = CardView()
    var minGridSize = 12
    
    //MARK: Public APIs
    fileprivate func configGrid() {
        grid.cellCount = gridSize
        grid.frame = CGRect(x: bounds.origin.x + cardsBoxOffsetX,
                            y: bounds.origin.y, width: bounds.width - cardsBoxOffsetX*2,
                            height: bounds.height - cardSBoxHeightMargin)
    }
    
    fileprivate func adjustGridAndSetPilesLocation() {
        configGrid()
        
        let cellWidth = grid[0]!.width
        let cellHeight = grid[0]!.height
        
        dealPile.frame = CGRect(x: max(bounds.width/2.0 - cellWidth - cardPileToCenterHorizontalOffset, cardsBoxOffsetX),
                                y: bounds.origin.y + bounds.height - cellHeight - cardPileToBottomOffset,
                                width: max(cellWidth, minPileHight*cardRatio),
                                height: max(cellHeight, minPileHight)
        ).insetBy(dx: cardInset*grid.aspectRatio, dy: cardInset)
        
        discardPile.frame = CGRect(x: min(bounds.width/2.0 + cardPileToCenterHorizontalOffset, bounds.width - cardsBoxOffsetX - cellWidth),
                                   y: bounds.origin.y + bounds.height - cellHeight - cardPileToBottomOffset,
                                   width: max(cellWidth, minPileHight*cardRatio),
                                   height: max(cellHeight, minPileHight)
        ).insetBy(dx: cardInset*grid.aspectRatio, dy: cardInset)
    }
    
    var gridSize: Int = 0 {
        didSet {
            grid.cellCount = gridSize
            setNeedsLayout()
       }
    }
    
    func moveupCards(from index: Int) {
        var cardToRemove = Card()
        for card in cardButtons.keys {
            if let cv = cardButtons[card] {
                if cv.gridIndex > index {
                    cv.gridIndex -= 1
                }
                else if cv.gridIndex == index {
                    cardToRemove = card
                }
            }
        }
        
        cardButtons.removeValue(forKey: cardToRemove)
        
        if self.gridSize > minGridSize {
            self.gridSize -= 1
        }
    }
    
    func cardView(_ card: Card) -> CardView? {
        return cardButtons[card]
    }
    
    func removeCard(_ card: Card) {
        if cardButtons.keys.first(where: {$0 == card }) != nil {
            cardButtons[card]?.displayState = .onDisplay
            cardButtons[card]?.removeFromSuperview()
            cardButtons.removeValue(forKey: card)
        }
    }
    
    func addCard(_ card: Card, gridIndex: Int) {
        let cv = CardView()
        cv.number = NumberOfSymbols(rawValue: card.number)!
        cv.shade = SymbolShade(rawValue: card.shade)!
        cv.shape = SymbolShape(rawValue: card.symbol)!

        switch card.color {
        case 0: cv.color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        case 1: cv.color = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        case 2: cv.color = UIColor.purple
        default: break
        }

        cv.displayState = .faceDown
        cv.gridIndex = gridIndex
        cardButtons[card] = cv
        addSubview(cv)
        
        cv.frame = dealPile.frame
        
        sendOneCard(card: cv)
    }
    
    
    func addPiles() {
        if (!subviews.contains(dealPile)) {
            dealPile.displayState = .faceDown
            dealPile.backText = "Add"
            addSubview(dealPile)
        }
        
        if (!subviews.contains(discardPile)) {
            discardPile.displayState = .faceDown
            addSubview(discardPile)
        }
        
        adjustGridAndSetPilesLocation()
    }
    
    func removeAll() {
        for card in cardButtons.keys {
            cardButtons[card]?.displayState = .onDisplay
            cardButtons[card]?.removeFromSuperview()
        }
        cardButtons.removeAll()
    }
    
    func setCardDisplayState(_ card: Card, displayState: CardDisplayState ) {
        cardButtons[card]?.displayState = displayState
    }
    
    func sendOneCard(card: CardView) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.4,
            delay: 0, //0.5 * Double(card.gridIndex),
            options: .curveEaseInOut,
            animations: {
                card.frame = self.grid[card.gridIndex]!.insetBy(dx: self.grid.aspectRatio * self.cardInset, dy: self.cardInset)
        },
            completion: { position in
                UIView.transition(
                    with: card,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        card.displayState = .onDisplay
                },
                    completion: { finished in
                })
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustGridAndSetPilesLocation()
       
        for card in cardButtons.keys {
            if let button = cardButtons[card], let cell = grid[button.gridIndex], button.displayState != .faceDown {
                button.frame = cell.insetBy(dx: grid.aspectRatio * cardInset, dy: cardInset) //.zoom(by: 0.85)
            }
        }
    }
        
    func getCardAtHitPoint(_ point: CGPoint) -> Card? {
        var retval: Card?
        for card in cardButtons.keys {
            if let cv = cardButtons[card] {
                if cv.frame.contains(point) {
                    retval = card
                }
            }
        }
        return retval
    }
    
    func isDealPileClicked(_ point: CGPoint) -> Bool {        
        return (subviews.contains(dealPile) && dealPile.frame.contains(point))
    }
}

extension CardsAreaView {
    var cardsBoxOffsetX : CGFloat { return 12.0 }
    var cardsBoxOffsetY : CGFloat { return 0.0 }
    var cardSBoxHeightMargin : CGFloat { return 100.0 }
    var cardPileToCenterHorizontalOffset : CGFloat { return 20.0 }
    var cardPileToBottomOffset : CGFloat { return 16.0 }
    var minPileHight : CGFloat { return 43.0 }
    var cardRatio : CGFloat { return 2.0 }
    var cardInset : CGFloat { return 3.0 }
}
