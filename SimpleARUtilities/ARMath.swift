//
//  ARMath.swift
//  Spool
//
//  Created by Matthew Slotkin on 1/17/17.
//  Copyright © 2017 Matthew Slotkin. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

class ARMath {
    
    //need to deal with altitude eventually
    static func relativeOrientationOf(deviceOrientation: DeviceOrientation, at currentLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> CustomAttitude {
        let absoluteRadialDistanceBetweenLocations = preciseRadialDistanceBetween(currentLocation, and: destination)
        
        let gravityZAngle = asin(deviceOrientation.gravity.z)
        let gravityXAngle = asin(deviceOrientation.gravity.x)
        
        let truePhoneHeading = backOfPhoneHeading(heading: deviceOrientation.heading, gravity: deviceOrientation.gravity)
        
        let relativeRadialDistanceGivenHeading = radialDifferenceBetween(heading: truePhoneHeading, and: absoluteRadialDistanceBetweenLocations)
        
        //print("yaw: \(gravityXAngle) roll: \(relativeRadialDistanceGivenHeading) pitch: \(gravityZAngle)")
        
        return CustomAttitude(pitch: gravityZAngle, yaw: gravityXAngle, roll: relativeRadialDistanceGivenHeading)
    }
    
    static func screenCoordinatesGivenOrientation(deviceOrientation: DeviceOrientation, at currentLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> Translation2D {
        
        let attitude = relativeOrientationOf(deviceOrientation: deviceOrientation, at: currentLocation, to: destination)
        
        return object2DCenterPositionOnScreenGivenAttitude(attitude: attitude)
    }
    
    static func object2DCenterPositionOnScreenGivenAttitude(attitude: Attitude) -> Translation2D {
        
        let point = Point3D(x: 0, y: 0, z: 1)
        
        let pitchRotated = point.rotate(radians: -attitude.pitch, axis: .x)
        let yawRotated = pitchRotated.rotate(radians: -attitude.yaw, axis: .z)
        let rollRotated = yawRotated.rotate(radians: -attitude.roll, axis: .y)
        
        
        //print("ATTITUDE: pitch:\(attitude.pitch) roll:\(attitude.roll) yaw:\(attitude.yaw)")
        
        let xRadianAdjustment = asin(rollRotated.x)
        let yRadianAdjustment = asin(rollRotated.y)
        
        let xAdjustment = AngleUtilities.degreesFromRadians(xRadianAdjustment) * fieldOfViewToDegreesConstant
        let yAdjustment = AngleUtilities.degreesFromRadians(yRadianAdjustment) * fieldOfViewToDegreesConstant
        
        return Translation2D(x: xAdjustment, y: yAdjustment, zPosition: rollRotated.z, rotation: -attitude.yaw)
    }
    
    static func preciseRadialDistanceBetween(_ source: CLLocationCoordinate2D, and: CLLocationCoordinate2D) -> Double {
        let lat1 = AngleUtilities.radiansFromDegrees(source.latitude)
        let lat2 = AngleUtilities.radiansFromDegrees(and.latitude)
        let lng1 = AngleUtilities.radiansFromDegrees(source.longitude)
        let lng2 = AngleUtilities.radiansFromDegrees(and.longitude)
        
        let y = sin(lng2 - lng1) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lng2 - lng1)
        let result = atan2(y, x)
        return result
    }
    
    private static let fieldOfViewToDegreesConstant = 10.0
    
    private static func backOfPhoneHeading(heading: CLLocationDirection, gravity: CMAcceleration) -> CLLocationDirection {
        let gravityXAngle = AngleUtilities.degreesFromRadians(asin(gravity.x))
        return heading - gravityXAngle
    }
    
    private static func radialDifferenceBetween(heading: CLLocationDirection, and radialOffset: Double) -> Double {
        return AngleUtilities.radiansAdjustmentToNegPiToPiSpace(radians: AngleUtilities.radiansFromDegrees(heading) - radialOffset)
    }
}

struct Point3D {
    var x: Double
    var y: Double
    var z: Double
    
    func rotate(radians: Double, axis: RotationAxis) -> Point3D {
        switch axis {
        case .x:
            let rotationMatrix = Point3D.generateRotationMatrixOnXAxis(radians: radians)
            return multiplyRotationMatrix(rotationMatrix: rotationMatrix)
        case .y:
            let rotationMatrix = Point3D.generateRotationMatrixOnYAxis(radians: radians)
            return multiplyRotationMatrix(rotationMatrix: rotationMatrix)
        case .z:
            let rotationMatrix = Point3D.generateRotationMatrixOnZAxis(radians: radians)
            return multiplyRotationMatrix(rotationMatrix: rotationMatrix)
        }
    }
    
    enum RotationAxis {
        case x
        case y
        case z
    }
    
    private func multiplyRotationMatrix(rotationMatrix: CMRotationMatrix) -> Point3D {
        let newX = x * rotationMatrix.m11 + y * rotationMatrix.m12 + z * rotationMatrix.m13
        let newY = x * rotationMatrix.m21 + y * rotationMatrix.m22 + z * rotationMatrix.m23
        let newZ = x * rotationMatrix.m31 + y * rotationMatrix.m32 + z * rotationMatrix.m33
        return Point3D(x: newX, y: newY, z: newZ)
    }
    
    private static func generateRotationMatrixOnXAxis(radians: Double) -> CMRotationMatrix {
        return CMRotationMatrix(m11: 1, m12: 0, m13: 0, m21: 0, m22: cos(radians), m23: -sin(radians), m31: 0, m32: sin(radians), m33: cos(radians))
    }
    
    private static func generateRotationMatrixOnYAxis(radians: Double) -> CMRotationMatrix {
        return CMRotationMatrix(m11: cos(radians), m12: 0, m13: sin(radians), m21: 0, m22: 1, m23: 0, m31: -sin(radians), m32: 0, m33: cos(radians))
    }
    
    private static func generateRotationMatrixOnZAxis(radians: Double) -> CMRotationMatrix {
        return CMRotationMatrix(m11: cos(radians), m12: -sin(radians), m13: 0, m21: sin(radians), m22: cos(radians), m23: 0, m31: 0, m32: 0, m33: 1)
    }
}

struct DeviceOrientation {
    var gravity: CMAcceleration
    var heading: CLLocationDirection
}

struct Translation2D {
    var x: Double
    var y: Double
    var zPosition: Double
    var rotation: Double
}
