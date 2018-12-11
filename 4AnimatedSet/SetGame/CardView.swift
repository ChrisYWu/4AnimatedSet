//
//  CardView.swift
//  3GraphicalSet
//
//  Created by Chris Wu on 11/15/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

enum CardDisplayState: Int {
    case faceDown = 0
    case chosen = 1
    case matched = 2
    case mismatched = 3
    case suggested = 4
    case onDisplay = 5
}

class CardView: UIView {
    var number: NumberOfSymbols = .none  {
        didSet {
            if ( number != .none ) {
                addSymbols(number.rawValue)
            }
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    var color: UIColor = UIColor.lightGray  { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var shape: SymbolShape = .diamond  { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var shade: SymbolShade = .outline { didSet { setNeedsDisplay(); setNeedsLayout() }}
    var displayState: CardDisplayState = .faceDown { didSet { setNeedsDisplay(); setNeedsLayout()}}
    var backText: String = "" { didSet { setNeedsDisplay(); setNeedsLayout()}}
    var gridIndex : Int = 0
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }
    
    private var cornerString: NSAttributedString {
        return centeredAttributedString(backText, fontSize: labelFontSize)
    }
    
    private lazy var backLabel = createLabel()
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private func configBackLabel(_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
    }
    
    private var symbols = [SymbolView]()
    
    private func addSymbols(_ number: Int) {
        if number >= 0 {
            for _ in 0 ... number {
                addASymbol()
            }
        }
    }
    
    fileprivate func drawBackgroundToFillBound() {
        //This fills the rounded conner cutoff
        let totalArea = UIBezierPath(rect: bounds)
        
        var color = superview?.backgroundColor
        if (color == nil) {
            color = superview?.superview?.backgroundColor
        }
        
        color?.setFill()
        color?.setStroke()
        totalArea.lineWidth = 1
        totalArea.fill()
        totalArea.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        drawBackgroundToFillBound()
        
        //This fills the front or back with rounded conners
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        
        if (displayState == .faceDown) {
            for sb in subviews {
                if sb != backLabel {
                    sb.removeFromSuperview()
                }
            }
            UIColor.gray.setFill()
        }
        else {
            for sb in subviews {
                if sb == backLabel {
                    sb.removeFromSuperview()
                }
            }
            
            UIColor.white.setFill()

            if (displayState == .onDisplay ) {
                layer.cornerRadius = 0
                layer.borderWidth = 0
            }
            else {
                layer.cornerRadius = cornerRadius
                layer.borderWidth = cornerRadius * SizeRatio.borderWidthToCornerRadius
                
                switch displayState {
                case .mismatched: layer.borderColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 0.6946168664)
                case .matched: layer.borderColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 0.7621200771)
                case .suggested: layer.borderColor = #colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 0.71)
                case .chosen: layer.borderColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 0.569536601)
                default: break
                }
            }
        }
        roundedRect.fill()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ensureSymbols()
        
        if displayState != .faceDown {
            let x = effectiveWidth, y = effectiveHeight

            switch number {
            case .one:
                let symbol = symbols[0]
                symbol.frame.origin = CGPoint(x: 0.5 * x, y: 0.5 * y).offsetBy(dx: -symbol.bounds.width/2, dy: -symbol.bounds.height/2)

            case .two:
                var symbol = symbols[0]
                symbol.frame.origin = CGPoint(x: 0.355 * x, y: 0.5 * y).offsetBy(dx: -symbol.bounds.width/2, dy: -symbol.bounds.height/2)
                
                symbol = symbols[1]
                symbol.frame.origin = CGPoint(x: 0.645 * x , y: 0.5 * y).offsetBy(dx: -symbol.bounds.width/2, dy: -symbol.bounds.height/2)
                
            case .three:
                var symbol = symbols[0]
                symbol.frame.origin = CGPoint(x: 0.23 * x , y: 0.5 * y).offsetBy(dx: -symbol.bounds.width/2, dy: -symbol.bounds.height/2)
                
                symbol = symbols[1]
                symbol.frame.origin = CGPoint(x: 0.5 * x , y: 0.5 * y).offsetBy(dx: -symbol.bounds.width/2, dy: -symbol.bounds.height/2)
                
                symbol = symbols[2]
                symbol.frame.origin = CGPoint(x: 0.77 * x , y: 0.5 * y).offsetBy(dx: -symbol.bounds.width/2, dy: -symbol.bounds.height/2)
                
            case .none: break
            }            
        }
        else {
            if (backText != "") {
                configBackLabel(backLabel)
                backLabel.center = CGPoint(x:bounds.width/2, y:bounds.height/2)
                //print(backLabel.text)
            }
        }
    }
    
    private func addASymbol() {
        if (displayState != .faceDown) {
            let symbol = SymbolView()
            configSymbol(symbol)
            addSubview(symbol)
            symbols.append(symbol)
        }
    }
    
    private func ensureSymbols() {
        if displayState == .faceDown {
            symbols.removeAll()
        }
        else if symbols.count == 0 {
            addSymbols(number.rawValue)
        }
        else {
            for s in symbols {
                configSymbol(s)
            }
        }
    }
    
    private func configSymbol(_ symbol: SymbolView) {
        symbol.color = color
        symbol.shape = shape
        symbol.shade = shade
        symbol.frame.size = CGSize(width: 0.18 * effectiveWidth, height: 0.37 * effectiveWidth)
        //symbol.frame = symbol.frame.insetBy(dx: SizeRatio.symbolInset, dy: SizeRatio.symbolInset)
    }

}

extension CardView {
    private struct SizeRatio {
        static let fontSizeToBoundsHeight: CGFloat = 0.35
        static let borderWidthToCornerRadius: CGFloat = 0.6
        static let cornerRadiusToBoundsHeight: CGFloat = 0.08
        static let symbolInset: CGFloat = 3.0
        static let aspectRatio: CGFloat = 1.8
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var effectiveWidth: CGFloat {
        return bounds.width
    }
    
    private var effectiveHeight: CGFloat {
        return bounds.height
    }
    
    private var labelFontSize: CGFloat {
        return bounds.size.height * SizeRatio.fontSizeToBoundsHeight
    }
    
//    private var cornerOffset: CGFloat {
//        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
//    }
}
