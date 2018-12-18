//
//  ViewController.swift
//  Concentration
//
//  Created by Chris Wu on 10/26/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController {

    private lazy var game = Concentration(numberOfPairOfCards: numberOfPairOfCards)
    var theme: Int = -1
    {
        didSet {
            if cardButtons != nil {
                setGameUI()
                updateViewFromModel()
            }
        }
    }
    
    var themeNotSet = true
    
    override func viewDidLoad() {
        print("view did load: numberOfPairOfCards = \(numberOfPairOfCards)")
        if (theme > -1) {
            setGameUI()
        }
    }
    
    private func setGameUI(){
        let (emojiChoices, cardBGColor) = ConcentrationViewController.emojiChoices[theme]
        currentEmojiChoies = emojiChoices
        cardBackGroundColor = cardBGColor
        
        for index in allCardButtons.indices{
            allCardButtons[index].backgroundColor = cardBGColor
        }
        
        emoji = [:]
    }
    
    var numberOfPairOfCards : Int {
        //return 10
        return (cardButtons.count + 1) / 2
    }
    
    private static var emojiChoices =
        [
            (["🐶","🐱","🐭","🦄","🐔","🐸","🐤","🐥", "🦉", "🐒", "🦕", "🐡"], #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)),
            //(["6️⃣","7️⃣","8️⃣","9️⃣","0️⃣","1️⃣","2️⃣","3️⃣", "4️⃣", "5️⃣", "🔟", "#️⃣"], #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)),
            (["😀","😍","🤓","😜","🤩","😩","😡","😰", "🥺", "😤", "😊", "🤒"], #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)),
            (["🍏","🍊","🥑","🍆","🍋","🍅","🥦","🥒", "🌽", "🥔", "🍇", "🍑"], #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)),
            (["⚽️","🏀","🏈","⚾️","🎾","🏐","🏉","🎱", "🥊", "🏓", "⛳️", "⛸"], #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
        ]
    
    private lazy var cardBackGroundColor = ConcentrationViewController.emojiChoices[theme].1
    private lazy var currentEmojiChoies = ConcentrationViewController.emojiChoices[theme].0
    
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBOutlet private var gameScore: UILabel!
    @IBOutlet private weak var newGameButton: UIButton!

    @IBOutlet private var allCardButtons: [UIButton]!
    
    private var cardButtons: [UIButton]! {
       return allCardButtons?.filter{ !$0.superview!.isHidden }
    }
    

    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        }
    }
    
    @IBAction private func newGame() {        
        print("[new game], theme index= \(theme), numberOfPairsOfCards=\(numberOfPairOfCards)")
        game = Concentration(numberOfPairOfCards: numberOfPairOfCards)
        setGameUI()
        updateViewFromModel()
    }
    
    
    private func updateViewFromModel() {
        //print("current date = \(Date())")
        //print("updateViewFromModel, cardButtons.count=\(self.cardButtons.count)")
        for index in 0 ..< self.game.cards.count {
            let button = self.cardButtons[index]
            let card = self.game.cards[index]
            //print("index = \(index), card \(card.identifier), isFaceUp: \(card.isFaceUp), \(String(describing: button.superview?.isHidden))")
            // Set logic and not the flip logic
            if card.isFaceUp {
                button.setTitle(self.emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)     // UIColor.white
            }
            else{
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) : self.cardBackGroundColor
            }
        }
    }
    
    private var emoji = [Int: String]()
    
    private func emoji(for card:ConcentrationCard) -> String {
        if emoji[card.identifier] == nil, currentEmojiChoies.count > 0 {
            emoji[card.identifier] = currentEmojiChoies.remove(at: currentEmojiChoies.count.arc4random)
//            print("currentEmojiChoies.count=\(currentEmojiChoies.count)")
//            print("\(emoji[card.identifier]!)")
        }
        
        return emoji[card.identifier] ?? "?"
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        print("\(Date()) > trait collection did change, cardButtons.count=\(cardButtons.count)")
        if (cardButtons.count != allCardButtons.count && theme > -1) {
            //This allow the show/hide logic happen, there has to be a better way
            //And also if the thing starts from landscape mode it just doesn't work
            Timer.scheduledTimer(withTimeInterval: 0.1,
                                 repeats: false)
            { timer in
                self.updateViewFromModel()
            }
        }
        
        switch traitCollection.horizontalSizeClass {
        case .compact :
            print("horizontalSizeClass == .compact")
        case .regular :
            print("horizontalSizeClass == .regiular")
        case .unspecified :
            print("horizontalSizeClass == .unspecified")
        }
        
        switch traitCollection.verticalSizeClass {
        case .compact :
            print("verticalSizeClass == .compact")
        case .regular :
            print("verticalSizeClass == .regiular")
        case .unspecified :
            print("verticalSizeClass == .unspecified")
        }
        
       
//        print("traitCollection.horizontalSizeClass = \(traitCollection.horizontalSizeClass)")
//        print("traitCollection.verticalSizeClass = \(traitCollection.verticalSizeClass)")

        //Here it is still too early to updateViewFromModel, since the number of visible buttons are not known the first time this happens. Yet updateViewFromModel will case the game to be initialized and the number of visible buttons know
    }
    
    override func viewWillLayoutSubviews() {
        //print("\(Date()) > viewWillLayoutSubviews, cardButtons.count=\(cardButtons.count)")
        //This is actually called twice, the first time didn't seem to work too well cause the visible buttons didn't react to trait collection. If we call updateViewFromModel, it will be too early to initialize the game
        //This gets called too often, on every redraw it seems getting called
    }
}
