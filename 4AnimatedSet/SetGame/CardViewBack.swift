//
//  CardViewBack.swift
//  4AnimatedSet
//
//  Created by Chris Wu on 12/5/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

@IBDesignable
class CardViewBack: UIView {

    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
//        roundedRect.addClip()
        
        UIColor.red.setFill()
        roundedRect.fill()
        
        roundedRect.lineWidth = 2
        UIColor.purple.setStroke()
        roundedRect.stroke()
        print("bounds = \(bounds)")
    }
    

}

extension CardViewBack {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let padding: CGFloat = 0.00
    }
    
    private var cornerRadius: CGFloat {
        //print ("bounds.size.height = \(bounds.size.height)")
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    
    private var effectiveWidth: CGFloat {
        return bounds.width * (1.0 - SizeRatio.padding)
    }
    
    private var paddingWidth: CGFloat {
        return bounds.width * SizeRatio.padding
    }
    
    private var paddingHeight: CGFloat {
        return bounds.height * SizeRatio.padding
    }
    
    private var effectiveHeight: CGFloat {
        return bounds.height * (1.0 - SizeRatio.padding)
    }
    
}
