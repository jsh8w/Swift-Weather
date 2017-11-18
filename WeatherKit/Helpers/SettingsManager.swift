//
//  SettingsManager.swift
//  WeatherFrontKit
//
//  Created by James Shaw on 29/10/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

open class SettingsManager: NSObject {

    let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!

    open class func setup() {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        if (userDefaults.object(forKey: "temperatureUnit") == nil) &&
            (userDefaults.object(forKey: "speedUnit") == nil) &&
            (userDefaults.object(forKey: "pageIndex") == nil) {

            // If not saved, save default settings
            userDefaults.set(true, forKey: "temperatureUnit")
            userDefaults.set(true, forKey: "speedUnit")
            userDefaults.set(0, forKey: "pageIndex")
            userDefaults.synchronize()
        }
    }

    open class func isCelsius() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        if userDefaults.bool(forKey: "temperatureUnit") == true {
            return true
        }

        return false
    }

    open class func setTemperature(celsius: Bool) {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        userDefaults.set(celsius, forKey: "temperatureUnit")
    }

    open class func isMPH() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        if userDefaults.bool(forKey: "speedUnit") == true {
            return true
        }

        return false
    }

    open class func setSpeed(mph: Bool) {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        userDefaults.set(mph, forKey: "speedUnit")
    }

    open class func pageIndex() -> Int {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        let pageIndex = userDefaults.integer(forKey: "pageIndex")
        return pageIndex
    }

    open class func setPageIndex(index: Int) {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        userDefaults.set(index, forKey: "pageIndex")
    }

    open class func widgetExpanded() -> Bool {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        let widgetExpanded = userDefaults.bool(forKey: "widgetExpanded")
        return widgetExpanded
    }

    open class func setWidgetExpanded(expanded: Bool) {
        let userDefaults = UserDefaults(suiteName: "group.com.weather.app")!
        userDefaults.set(expanded, forKey: "widgetExpanded")
    }
}
