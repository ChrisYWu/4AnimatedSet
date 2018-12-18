//
//  Extensions.swift
//  3GraphicalSet
//
//  Created by Chris Wu on 11/15/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

extension Int {
    // MARK arc4random
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        }
        else if self < 0 {
            return Int(arc4random_uniform(UInt32(-self)))
        }
        else {
            return 0
        }
    }
    
    // MARK sameOrMutexIn3
    func sameOrMutexIn3(firstNumber:Int, secondNumber:Int) -> Bool
    {
        if firstNumber < 0 || firstNumber > 2 || secondNumber < 0 || secondNumber > 2 {
            return false
        }
        else if (firstNumber == secondNumber)
        {
            return self == secondNumber
        }
        else {
            return self != firstNumber && self != secondNumber
        }
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}

extension Double {
    var arc4random: Double {
        return self * (Double(arc4random_uniform(UInt32.max))/Double(UInt32.max))
    }
}
