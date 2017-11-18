//
//  Forecast.swift
//  Weather
//
//  Created by James Shaw on 19/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

// This class represents the weather forecast for a particular latitude and longitude.

import UIKit

open class Forecast: NSObject {
    
    // Latitude of location
    open var latitude: Float?
    
    // Longitude of location
    open var longitude: Float?
    
    // Timezone e.g Europe/London
    open var timezone: String?
    
    // The current forecast for the location
    open var currently: DataPoint?
    
    // The minute-by-minute forecast for the next hour for the location
    open var minutely: DataBlock?
    
    // The hour-by-hour forecast for the next day for the location
    open var hourly: DataBlock?
    
    // The day-by-day forecast for the next week for the location
    open var daily: DataBlock?

    public func backgroundColour() -> UIColor {
        var backgroundColour = Constants.gradientColours["clear-day"]

        guard let icon = self.currently?.icon else { return backgroundColour! }
        backgroundColour = Constants.gradientColours[icon]
        guard let summary = self.currently?.summary else { return backgroundColour! }

        if summary == "Partly Cloudy" || summary == "Mostly Cloudy" {
            if let cloudCover = self.currently?.cloudCover {
                backgroundColour = self.backgroundColourWith(cloudCover: cloudCover, icon: icon)
            } else {
                backgroundColour = Constants.gradientColours[icon]
            }
        } else {
            backgroundColour = Constants.gradientColours[icon]
        }

        return backgroundColour!
    }

    public func backgroundColourWith(cloudCover: Float, icon: String) -> UIColor {
        if cloudCover < 0.15 {
            return Constants.gradientColours["clear-day"]!
        } else if cloudCover < 0.4 {
            return Constants.gradientColours[icon]!
        } else if cloudCover < 0.7 {
            return Constants.gradientColours["mostly-cloudy"]!
        } else {
            return Constants.gradientColours["cloudy"]!
        }
    }
}
