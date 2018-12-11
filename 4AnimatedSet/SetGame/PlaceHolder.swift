//
//  PlaceHolder.swift
//  4AnimatedSet
//
//  Created by Chris Wu on 12/7/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

@IBDesignable
class PlaceHolder: UIView {

    override func draw(_ rect: CGRect) {
        //print("Drawing Place Holder")
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
        
        let cardArea = UIBezierPath(roundedRect: bounds.insetBy(dx: 3, dy: 3), cornerRadius: 3)
        color = UIColor.purple
        cardArea.addClip()
        
        color?.setFill()
        color?.setStroke()
        cardArea.lineWidth = 1
        cardArea.fill()
        cardArea.stroke()

    }

}
