//
//  BaseSingleShapeView.swift
//  3GraphicalSet
//
//  Created by Chris Wu on 11/14/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

@IBDesignable class SymbolView: UIView {
    
    var color: UIColor = UIColor.lightGray  { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var shape: SymbolShape = .diamond  { didSet { setNeedsDisplay(); setNeedsLayout() } }
    var shade: SymbolShade = .outline { didSet { setNeedsDisplay(); setNeedsLayout() }}

    private static var counter = 0
    override func draw(_ rect: CGRect) {
        //Draw the white background
        var path = UIBezierPath(rect: bounds)
        UIColor.white.setFill()
        UIColor.white.setStroke()
        path.fill()
        path.stroke()
        
        //Draw the card face
        path = UIBezierPath()
        
        outlinePath(path)
        drawWithPath(path)
    }
    
    func outlinePath(_ path: UIBezierPath)
    {
        let x = shapeWidth
        let y = shapeHeight
        
        switch shape {
        case .oval:
            path.addArc(withCenter: CGPoint(x: x/2, y: x/2), radius: 0.45 * x, startAngle: CGFloat.pi, endAngle: 0.0, clockwise: true)
            path.addLine(to: CGPoint(x: 0.95 * x, y: 0.75*y ))
            path.addArc(withCenter: CGPoint(x: x/2, y: 0.75*y), radius: 0.45 * x, startAngle: 0.0, endAngle: CGFloat.pi, clockwise: true)
            path.close()
        case .diamond:
            path.move(to: CGPoint(x: x/2, y: 0.03*y))
            path.addLine(to: CGPoint(x: 0.97*x, y:y/2))
            path.addLine(to: CGPoint(x:x/2, y:y*0.97))
            path.addLine(to: CGPoint(x:0.03*x, y:y/2))
            path.close()
        case .squiggle:
            path.move(to: CGPoint(x: 0.103 * x, y: 0.181 * y))
            path.addQuadCurve(to: CGPoint(x:0.135 * x, y: 0.077 * y), controlPoint: CGPoint(x: 0.00 * x, y: 0.128 * y))
            path.addQuadCurve(to: CGPoint(x:0.603 * x, y: 0.060 * y), controlPoint: CGPoint(x: 0.375 * x, y: 0.013 * y))
            path.addQuadCurve(to: CGPoint(x:0.760 * x, y: 0.448 * y), controlPoint: CGPoint(x: 1.05 * x, y: 0.169 * y))
            path.addQuadCurve(to: CGPoint(x:0.903 * x, y: 0.802 * y), controlPoint: CGPoint(x: 0.610 * x, y: 0.620 * y))
            path.addQuadCurve(to: CGPoint(x:0.921 * x, y: 0.903 * y), controlPoint: CGPoint(x: 1.02 * x, y: 0.856 * y))
            path.addQuadCurve(to: CGPoint(x:0.486 * x, y: 0.907 * y), controlPoint: CGPoint(x: 0.779 * x, y: 0.965 * y))
            path.addQuadCurve(to: CGPoint(x:0.203 * x, y: 0.491 * y), controlPoint: CGPoint(x: 0.005 * x, y: 0.791 * y))
            path.addQuadCurve(to: CGPoint(x:0.103 * x, y: 0.181 * y), controlPoint: CGPoint(x: 0.345 * x, y: 0.291 * y))
            
            path.apply(CGAffineTransform(scaleX: 1.02, y: 1.0))
            
        }
    }
    
    func drawWithPath(_ path: UIBezierPath)
    {
        switch shade {
        case .outline:
            color.setStroke()
            //Shrink the shape smaller to allow for stoke the outline
            path.apply(CGAffineTransform(scaleX: 1.0 - (Const.outlineStrokeWidth-1) / shapeWidth, y: 1.0 - (Const.outlineStrokeWidth-1)/shapeHeight))
            
            path.lineWidth = Const.outlineStrokeWidth
            path.stroke()
        case .solidFill:
            color.setFill()

            path.lineWidth = Const.standardStrokeWidth
            path.fill()
        case .stripe:
            color.setStroke()

            path.addClip()
            path.lineWidth = Const.outlineStrokeWidth
            path.stroke()
            
            let stripePath = UIBezierPath()
            stripePath.lineWidth = Const.stripeStrokeWidth
            let x = Double(shapeWidth)
            let y = Double(shapeHeight)
            let stripStep = Const.stripeStep
            let step = Int(y/stripStep)
            
            for index in 1 ... step {
                stripePath.move(to: CGPoint(x: 0, y: Double(index) * stripStep))
                stripePath.addLine(to: CGPoint(x: x, y: Double(index) * stripStep))
                stripePath.stroke()
            }

        }
    }

}

enum SymbolShade : Int {
    case outline
    case solidFill
    case stripe
}

enum SymbolColor : Int {
    case red
    case green
    case purple
}

enum SymbolShape : Int {
    case diamond
    case oval
    case squiggle
}

enum NumberOfSymbols : Int {
    case one
    case two
    case three
    case none
}

extension SymbolView {
    private struct Const {
        static let outlineStrokeWidth: CGFloat = 1.75
        static let standardStrokeWidth: CGFloat = 1.0
        static let stripeStep: Double = 3.0
        static let stripeStrokeWidth: CGFloat = 1.0
        static let shapeZomeToBounds: CGFloat = 0.9
    }
    
    private var shapeWidth: CGFloat {
        return bounds.width
    }
    
    private var shapeHeight: CGFloat {
        return bounds.height
    }
    
    
    
}
