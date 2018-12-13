//
//  Card.swift
//  Concentration
//
//  Created by Chris Wu on 10/28/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import Foundation

struct ConcentrationCard {
    //
    var isFaceUp = false
    {
        didSet{
            if isFaceUp {
                flipCount += 1
            }
        }
    }
    
    var isMatched = false
    var identifier:Int
    var flipCount = 0
    
    private static var identifierFactory = 0
    
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        identifier = ConcentrationCard.getUniqueIdentifier()
    }
        
}
