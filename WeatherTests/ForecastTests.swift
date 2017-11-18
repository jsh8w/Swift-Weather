//
//  ForecastTests.swift
//  WeatherTests
//
//  Created by James Shaw on 06/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import XCTest
@testable import WeatherFrontKit

class ForecastTests: XCTestCase {

    var inputJSON: [String: Any] = [:]

    override func setUp() {
        super.setUp()

        self.inputJSON = [
            "time": 1470142800,
            "summary": "Light Rain",
            "icon": "rain",
            "precipIntensity": 0.0273,
            "precipProbability": 0.52,
            "precipType": "rain",
            "temperature": 70.09,
            "apparentTemperature": 70.09,
            "dewPoint": 59.37,
            "humidity": 0.69,
            "windSpeed": 10.52,
            "windBearing": 234,
            "visibility": 6.21,
            "cloudCover": 0.56,
            "pressure": 1017.29,
            "ozone": 305.72
        ]
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testBackgroundColourRain() {
        let dataPoint = DataPoint(object: self.inputJSON as NSDictionary)
        let forecast = Forecast()
        forecast.currently = dataPoint

        let backgroundColour = forecast.backgroundColour()

        XCTAssertEqual(backgroundColour, Constants.gradientColours["rain"]!)
    }

    func testBackgroundColourCloudy() {
        self.inputJSON["summary"] = "Mostly Cloudy"
        self.inputJSON["cloudCover"] = 0.9
        self.inputJSON["icon"] = "cloudy"
        
        let dataPoint = DataPoint(object: self.inputJSON as NSDictionary)
        let forecast = Forecast()
        forecast.currently = dataPoint

        let backgroundColour = forecast.backgroundColour()
        
        XCTAssertEqual(backgroundColour, Constants.gradientColours["cloudy"]!)
    }
}
