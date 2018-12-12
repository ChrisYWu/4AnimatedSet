//
//  SetGame.swift
//  2SetGame
//
//  Created by Chris Wu on 11/2/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import Foundation

class SetGame: CustomStringConvertible {
    // MARK: Instance variables
    private var runnerIndex = 0
    var cheatMode = false
    
    private(set) var chosenCards = [Card]()
    private(set) var numberOfSetMatched = 0
    
    var scale: Double {
        if numberOfCardsOnTable > 12 {
            return Double(numberOfCardsOnTable) / 12.0
        }
        else {
            return 1.0
        }
    }
    
    var scaledScore = 0.0
    private var cards = [Card]()
    private var dimension = 4
    
    var totalCardsOnDeck : Int {
        return cards.filter{ $0.state == CardState.inDeck }.count
    }
    
    // MARK: APIs
    var numberOfCardsOnTable: Int {
        return cards.filter{ $0.state == CardState.onDisplay }.count
    }
    
    var ThreeCardSelected: Bool {
        return chosenCards.count == 3
    }
    
    func isTheCardSelected(_ card: Card) -> Bool {
        return chosenCards.contains(card)
    }
    
    var shortDescription: String {
        var retval = ""
        retval = "runnerIndex = \(runnerIndex)\n"
        retval += "total cards on display = \(cards.filter{ $0.state == .onDisplay }.count)\n"
        retval += "total cards chosen = \(chosenCards.count)\n"
        
        return retval
    }
    
    var description: String {
        var retval = shortDescription
        for index in 0..<cards.count{
            retval += "i[\(index)]" + cards[index].description + "\n" + cards[index].shortDescription + "\n"
        }
        return retval
    }
    
    var hasMoreCardsInDeck: Bool {
        return runnerIndex < cards.count
    }
    
    // MARK: Init(dim)
    init() {
        var card = Card()
        runnerIndex = 0
        scaledScore = 0.0
        
        for firstRound in 0...2
        {
            card.color = firstRound
            card.state = .inDeck
            for secondRound in 0...2
            {
                card.number = secondRound
                card.symbol = 0
                card.shade = 0
                if (dimension > 2)
                {
                    for thirdRound in 0...2
                    {
                        card.symbol = thirdRound
                        if (dimension == 4)
                        {
                            for fourthRound in 0...2
                            {
                                card.shade = fourthRound
                                let v = cards.count.arc4random
                                //print("count=\(cards.count), random=\(v)")
                                cards.insert(card, at: v)
                            }
                        }
                        else{
                            let v = cards.count.arc4random
                            //print("count=\(cards.count), random=\(v)")
                            cards.insert(card, at: v)
                        }
                    }
                }
                else {
                    let v = cards.count.arc4random
                    //print("count=\(cards.count), random=\(v)")
                    cards.insert(card, at: v)
                }
            }
        }
        
        //Swap the last card
        let v = cards.count.arc4random
        cards.insert(cards[cards.count - 1], at: v)
        cards.remove(at: cards.count - 1)
        
    }
    
    func selectCard(_ card: Card) {
        chosenCards.append(card)
    }
    
    var setMatchedString : String {
        numberOfSetMatched += 1
        return "\(numberOfSetMatched) Set" + (numberOfSetMatched<2 ? "" : "s")
    }
    
    func deselectCard(_ card: Card) {
        chosenCards.removeAll(where: {$0 == card})
    }
    
    func recyleAllSelectedCards() {
        for card in chosenCards {
            if let index = cards.index(of: card) {
                cards[index].state = .recycled
            }
        }
        chosenCards.removeAll()
    }
    
    func deselectAll() {
        chosenCards.removeAll()
    }
    
    func resetAllSelected() -> [Card] {
        let retval = chosenCards
        chosenCards.removeAll()
        return retval
    }
    
    func drawNextCardForDisplay() -> Card? {
        var retval: Card?
        if hasMoreCardsInDeck {
            cards[runnerIndex].state = .onDisplay
            retval = cards[runnerIndex]            
            runnerIndex += 1
        }
        else {
            retval = nil
        }
        return retval
    }
    
    func tryGetSelectedAsASet() -> (Bool, [Card]) {
        if chosenCards.count == 3 {
            if cheatMode {
                return (true, chosenCards)
            } else if chosenCards[0].matchesWithOtherTwo(firstCard: chosenCards[1], secondCard: chosenCards[2]) {
                return (true, chosenCards)
            }
            return (false, chosenCards)
        }
        else {
            return (false, [Card]())
        }
    }
    
    func findAMatchSet() -> [Card]? {
        for i1 in 0 ..< cards.count {
            for i2 in i1 + 1 ..< cards.count {
                for i3 in i2 + 1 ..< cards.count {
                    if cards[i1].state == .onDisplay && cards[i2].state == .onDisplay && cards[i3].state == .onDisplay  && cards[i1].matchesWithOtherTwo(firstCard: cards[i2], secondCard: cards[i3]) {
                        return [cards[i1], cards[i2], cards[i3]]
                    }
                }
            }
        }
        return nil
    }
    
    func shuffle() {
        for index in 0 ..< cards.count {
            if cards[index].state != .recycled {
                cards[index].state = .inDeck
            }
        }
        
        var newCards = cards.filter{$0.state == CardState.inDeck}
        let newCardsCount = newCards.count
        
        runnerIndex = 0
        cards = [Card]()
        for _ in 0 ..< newCardsCount {
            cards.insert(newCards.remove(at: newCards.count.arc4random), at: cards.count.arc4random)
        }
    }
}
