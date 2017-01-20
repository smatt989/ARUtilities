//
//  Attitude.swift
//  SimpleARUtilities
//
//  Created by Matthew Slotkin on 1/20/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreMotion

protocol Attitude {
    var pitch: Double { get }
    var yaw: Double { get }
    var roll: Double { get }
}

class CustomAttitude: Attitude {
    var pitch: Double
    var yaw: Double
    var roll: Double
    
    init(pitch: Double, yaw: Double, roll: Double) {
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
    }
}

extension CMAttitude: Attitude {
    
}
