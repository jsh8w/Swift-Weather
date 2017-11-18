//
//  Constants.swift
//  Weather
//
//  Created by James Shaw on 31/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import Foundation
import UIKit

public struct Constants {

    public static let darkSkyAPIKey = "ENTER_YOUR_DARK_SKY_KEY"
    public static let darkSkyAPIUrl = "https://api.darksky.net/forecast/\(Constants.darkSkyAPIKey)/"
    
    public static let googleAPIKey = "ENTER_YOUR_GOOGLE_PLACES_KEY"
    
    public static let gradientColours = [
        "clear-day" : UIColor(red: 50.0/255.0, green: 150.0/255.0, blue: 235.0/255.0, alpha: 1.0),
        "clear-night" : UIColor(red: 25.0/255.0, green: 30.0/255.0, blue: 55.0/255.0, alpha: 1.0),
        "rain" : UIColor(red: 120.0/255.0, green: 130.0/255.0, blue: 150.0/255.0, alpha: 1.0),
        "snow" : UIColor(red: 120.0/255.0, green: 130.0/255.0, blue: 150.0/255.0, alpha: 1.0),
        "sleet" : UIColor(red: 130.0/255.0, green: 140.0/255.0, blue: 160.0/255.0, alpha: 1.0),
        "wind" : UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0),
        "fog" : UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0),
        "mostly-cloudy" : UIColor(red: 205.0/255.0, green: 215.0/255.0, blue: 225.0/255.0, alpha: 1.0),
        "cloudy" : UIColor(red: 180.0/255.0, green: 190.0/255.0, blue: 200.0/255.0, alpha: 1.0),
        "partly-cloudy-day" : UIColor(red: 120.0/255.0, green: 180.0/255.0, blue: 245.0/255.0, alpha: 1.0),
        "partly-cloudy-night" : UIColor(red: 45.0/255.0, green: 55.0/255.0, blue: 70.0/255.0, alpha: 1.0),
        "hail" : UIColor(red: 130.0/255.0, green: 170.0/255.0, blue: 195.0/255.0, alpha: 1.0),
        "thunderstorm" : UIColor(red: 100.0/255.0, green: 120.0/255.0, blue: 140.0/255.0, alpha: 1.0),
        "tornado" : UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    ]
    
    public static let graphColours = [
        "clear-day" : UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.2),
        "light-rain" : UIColor(red: (140.0/255.0), green: (210.0/255.0), blue: (255.0/255.0), alpha: 1.0),
        "medium-rain" : UIColor(red: (100.0/255.0), green: (190.0/255.0), blue: (255.0/255.0), alpha: 1.0),
        "heavy-rain" : UIColor(red: (70.0/255.0), green: (170.0/255.0), blue: (255.0/255.0), alpha: 1.0),
        "snow" : UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.7),
        "sleet" : UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5),
        "wind" : UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.7),
        "fog" : UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 0.7),
        "mostly-cloudy" : UIColor(red: 205.0/255.0, green: 215.0/255.0, blue: 225.0/255.0, alpha: 1.0),
        "cloudy" : UIColor(red: 190.0/255.0, green: 200.0/255.0, blue: 210.0/255.0, alpha: 0.8),
        "partly-cloudy-day" : UIColor(red: 205.0/255.0, green: 215.0/255.0, blue: 225.0/255.0, alpha: 0.8),
        "hail" : UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 0.7),
        "thunderstorm" : UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0),
        "tornado" : UIColor(red: 200.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    ]
    
    public static let forecastIcons = [
        "clear-day" : "\u{f00d}",
        "clear-night" : "\u{f02e}",
        "rain" : "\u{f019}",
        "snow" : "\u{f01b}",
        "sleet" : "\u{f0b5}",
        "wind" : "\u{f050}",
        "fog" : "\u{f014}",
        "cloudy" : "\u{f013}",
        "partly-cloudy-day" : "\u{f002}",
        "partly-cloudy-night" : "\u{f086}",
        "hail" : "\u{f015}",
        "thunderstorm" : "\u{f01e}",
        "tornado" : "\u{f056}",
        "no-report" : "\u{f07b}",
        "temperature" : "\u{f055}",
        "feels-like" : "\u{f053}",
        "umbrella" : "\u{f084}",
        "humidity" : "\u{f07a}",
        "dew-point" : "\u{f078}",
        "sunrise" : "\u{f051}",
        "sunset" : "\u{f052}",
        "cloud-cover" : "\u{f041}",
        "wind-detail" : "\u{f079}",
        "direction-up" : "\u{f058}",
        "direction-down" : "\u{f044}"
    ]
    
    public static let fontAwesomeCodes = [
        "fa-refresh" : "\u{f021}",
        "fa-bars" : "\u{f0c9}",
        "fa-times" : "\u{f00d}",
        "fa-plus" : "\u{f067}",
        "fa-location-arrow" : "\u{f124}",
        "fa-angle-up" : "\u{f106}",
        "fa-angle-down" : "\u{f107}",
        "fa-show-more" : "\u{f135}"
    ]

    public struct Notifications {
        public static let locationFailed = Notification.Name(rawValue: "locationFailed")
        public static let locationFound = Notification.Name(rawValue: "locationFound")
        public static let addressToCoordinatesFailed = Notification.Name(rawValue: "addressToCoordinatesFailed")
        public static let addressToCoordinatesComplete = Notification.Name(rawValue: "addressToCoordinatesComplete")
        public static let coordinatesToAddressFailed = Notification.Name(rawValue: "coordinatesToAddressFailed")
        public static let coordinatesToAddressComplete = Notification.Name(rawValue: "coordinatesToAddressComplete")
        public static let downloadForecastComplete = Notification.Name(rawValue: "downloadForecastComplete")
        public static let downloadForecastFailed = Notification.Name(rawValue: "downloadForecastFailed")
        public static let unitsChanged = Notification.Name(rawValue: "unitsChanged")
        public static let backFromOrganiser = Notification.Name(rawValue: "backFromOrganiser")
        public static let goToPageViewIndex = Notification.Name(rawValue: "goToPageViewIndex")
    }
    
    public static let weatherFont = UIFont(name: "WeatherIcons-Regular", size: 24.0)
    public static let fontAwesome = UIFont(name: "FontAwesome", size: 20.0)
}
