//
//  UnitManager.swift
//  WeatherFrontKit
//
//  Created by James Shaw on 10/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

open class UnitManager: NSObject {

    open class func celsius(fahrenheit: Float) -> Float {
        return (fahrenheit - 32.0) * (5/9)
    }

    open class func kph(mph: Float) -> Float {
        return mph * 1.609344
    }
}
