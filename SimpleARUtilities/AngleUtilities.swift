//
//  AngleUtilities.swift
//  SimpleARUtilities
//
//  Created by Matthew Slotkin on 1/20/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation

class AngleUtilities {
    static func radiansFromDegrees(_ degrees: Double) -> Double {
        return degrees * M_PI / 180
    }
    
    static func degreesFromRadians(_ radians: Double) -> Double {
        return radians * 180 / M_PI
    }
    
    static func radiansAdjustmentToNegPiToPiSpace(radians: Double) -> Double {
        let scaledCorrectly = radians.truncatingRemainder(dividingBy: 2 * M_PI)
        if scaledCorrectly < -M_PI {
            return scaledCorrectly + 2 * M_PI
        } else if scaledCorrectly > M_PI {
            return scaledCorrectly - 2 * M_PI
        } else {
            return scaledCorrectly
        }
    }
}
