//
//  Concentration.swift
//  Concentration
//
//  Created by Chris Wu on 10/27/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import Foundation
class Concentration
{
    private(set) var cards = [ConcentrationCard]()
    private var startTime = Date()
    
    
    var elapsedSeconds : Int
    {
        return Int(Date().timeIntervalSince(startTime))
    }
    
    var totalFlipCount: Int {
        var counter = 0
        for index in 0 ..< cards.count{
            let flipCount = cards[index].flipCount
            counter += flipCount
        }
        //print ("FlipCount updated to be: \(counter)")
        return counter
    }
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            var foundIndex: Int?
            for index in 0 ..< cards.count {
                if cards[index].isFaceUp {
                    if foundIndex == nil {
                        foundIndex = index
                    }
                    else {
                        foundIndex = nil
                    }
                }
            }
            return foundIndex
        }
        set {
            for runner in cards.indices {
                cards[runner].isFaceUp = (runner == newValue)
            }
        }
    }
    
    var score: Int {
        var counter = 0
        for index in 0 ..< cards.count{
            let flipCount = cards[index].flipCount
            counter += flipCount < 2 ? 0 : 2 - flipCount
            if cards[index].isMatched {
                counter += 1
            }
        }
        //print ("Score updated to be: \(counter)")
        
        let timeElapsed = Date().timeIntervalSince(startTime)
        //print ("timeElapsed = \(timeElapsed) seconds")
        return counter - Int(timeElapsed*0.1)
    }
    
    func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in the cards")
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                //only one card up and this will be the second one, need to see if they match
                if (cards[matchIndex].identifier == cards[index].identifier) {
                    //Label both as matched is a match is found
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                //Regardless of matched or not, two is up and reset the onlyCard index
                cards[index].isFaceUp = true
            }
            else {
                // Either two cards are up or no card is up
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
        
        //print("index=\(index); cards[index].isFactUp=\(cards[index].isFaceUp); Cards[index].isMatched=\(cards[index].isMatched)")
        //print("indexOfOneAndOnlyFaceUpCard(after chooseCard) = \(String(describing: indexOfOneAndOnlyFaceUpCard))")
    }
    
    init(numberOfPairOfCards:Int) {
        assert(numberOfPairOfCards > 0, "Concentration.init(at: \(numberOfPairOfCards)): you must have at least one pair of cards")
        for _ in 0 ..< numberOfPairOfCards{
            let card = ConcentrationCard()
            cards.insert(card, at: cards.count.arc4random)
            cards.insert(card, at: cards.count.arc4random)
        }
        startTime = Date()        
    }
}
