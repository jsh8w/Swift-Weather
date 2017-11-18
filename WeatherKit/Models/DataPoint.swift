//
//  self.swift
//  Weather
//
//  Created by James Shaw on 19/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

// This class represents the weather at a particular point in time.

import UIKit

open class DataPoint: NSObject {
    
    // UNIX time (seconds since midnight GMT 1 Jan 1970) that data point occurs
    open var time: Int?
    
    // Text summary of data point
    open var summary: String?
    
    // Text summary of data point that can be used for icon
    open var icon: String?
    
    // Unix time for sunrise
    open var sunriseTime: Int?
    
    // Unix time for sunset
    open var sunsetTime: Int?
    
    // Precipitation Intensity
    open var precipIntensity: Float?
    
    // Precipitation Probability
    open var precipProbability: Float?
    
    // Precipitation Type e.g rain, drizzle, snow etc
    open var precipType: String?
    
    // Temperature (Fahrenheit) (not for daily data points)
    open var temperature: Float?
    
    // Temperature (Fahrenheit) which it feels like (not for daily data points)
    open var apparentTemperature: Float?
    
    // Minimum Daily Temperature (Fahrenheit)
    open var dailyMinTemperature: Float?
    
    // Maximum Daily Temperature (Fahrenheit)
    open var dailyMaxTemperature: Float?
    
    // Humidity
    open var humidity: Float?
    
    // Dew Point: Temperature
    open var dewPoint: Float?
    
    // Wind Speed
    open var windSpeed: Float?
    
    // Wind Direction. Represents the degrees (0-360) that the wind is coming FROM
    open var windDirection: Float?
    
    // Cloud Cover. Decimal (0-1)
    open var cloudCover: Float?

    public init(object: NSDictionary) {

        if let time = object["time"] as? Int {
            self.time = time
        }
        if let summary = object["summary"] as? String {
            self.summary = summary
        }
        if let icon = object["icon"] as? String {
            var iconString = icon
            if icon == "clear-night" {
                iconString = "clear-day"
            }
            else if icon == "partly-cloudy-night" {
                iconString = "partly-cloudy-day"
            }
            self.icon = iconString
        }
        if let sunriseTime = object["sunriseTime"] as? Int {
            self.sunriseTime = sunriseTime
        }
        if let sunsetTime = object["sunsetTime"] as? Int {
            self.sunsetTime = sunsetTime
        }
        if let precipIntensity = object["precipIntensity"] as? Float {
            self.precipIntensity = precipIntensity
        }
        if let precipProbability = object["precipProbability"] as? Float {
            self.precipProbability = precipProbability
        }
        if let precipType = object["precipType"] as? String {
            self.precipType = precipType
        }
        if let temperature = object["temperature"] as? Float {
            self.temperature = temperature
        }
        if let apparentTemperature = object["apparentTemperature"] as? Float {
            self.apparentTemperature = apparentTemperature
        }
        if let dailyMinTemperature = object["temperatureMin"] as? Float {
            self.dailyMinTemperature = dailyMinTemperature
        }
        if let dailyMaxTemperature = object["temperatureMax"] as? Float {
            self.dailyMaxTemperature = dailyMaxTemperature
        }
        if let humidity = object["humidity"] as? Float {
            self.humidity = humidity
        }
        if let dewPoint = object["dewPoint"] as? Float {
            self.dewPoint = dewPoint
        }
        if let windSpeed = object["windSpeed"] as? Float {
            self.windSpeed = windSpeed
        }
        if let windDirection = object["windBearing"] as? Float {
            self.windDirection = windDirection
        }
        if let cloudCover = object["cloudCover"] as? Float {
            self.cloudCover = cloudCover
        }
    }

    public func getRainColour() -> UIColor {
        guard let icon = self.icon else {
            return UIColor(white: 1.0, alpha: 0.1)
        }

        if icon == "rain" {
            if let precipIntensity = self.precipIntensity {
                switch self.getIntensityRange(precipIntensity: precipIntensity) {
                case 1:
                    return Constants.graphColours["light-rain"]!
                case 2:
                    return Constants.graphColours["medium-rain"]!
                case 3:
                    return Constants.graphColours["heavy-rain"]!
                default:
                    return Constants.graphColours["heavy-rain"]!
                }
            } else {
                return Constants.graphColours["medium-rain"]!
            }
        } else {
            return Constants.graphColours[icon]!
        }
    }

    public func getIntensityRange(precipIntensity: Float) -> Int {

        if precipIntensity < 0.017 {
            return 1
        } else if precipIntensity < 0.1 {
            return 2
        } else {
            return 3
        }
    }
}
