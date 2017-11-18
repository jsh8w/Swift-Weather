//
//  DataPointTests.swift
//  WeatherTests
//
//  Created by James Shaw on 04/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import XCTest
@testable import WeatherFrontKit

class DataPointTests: XCTestCase {

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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        let dataPoint = DataPoint(object: self.inputJSON as NSDictionary)

        XCTAssertEqual(dataPoint.time, 1470142800)
        XCTAssertEqual(dataPoint.summary, "Light Rain")
        XCTAssertEqual(dataPoint.icon, "rain")
        XCTAssertEqual(dataPoint.precipIntensity, 0.0273)
        XCTAssertEqual(dataPoint.precipProbability, 0.52)
        XCTAssertEqual(dataPoint.precipType, "rain")
        XCTAssertEqual(dataPoint.temperature, 70.09)
        XCTAssertEqual(dataPoint.apparentTemperature, 70.09)
        XCTAssertEqual(dataPoint.dewPoint, 59.37)
        XCTAssertEqual(dataPoint.humidity, 0.69)
        XCTAssertEqual(dataPoint.windSpeed, 10.52)
        XCTAssertEqual(dataPoint.windDirection, 234)
        XCTAssertEqual(dataPoint.cloudCover, 0.56)
    }

    func testGetRainColour() {
        let dataPoint = DataPoint(object: self.inputJSON as NSDictionary)

        dataPoint.precipIntensity = 0.001
        XCTAssertEqual(dataPoint.getRainColour(), Constants.graphColours["light-rain"]!)

        dataPoint.precipIntensity = 0.05
        XCTAssertEqual(dataPoint.getRainColour(), Constants.graphColours["medium-rain"]!)

        dataPoint.precipIntensity = 0.5
        XCTAssertEqual(dataPoint.getRainColour(), Constants.graphColours["heavy-rain"]!)

        dataPoint.precipIntensity = nil
        XCTAssertEqual(dataPoint.getRainColour(), Constants.graphColours["medium-rain"]!)

        dataPoint.icon = "clear-day"
        XCTAssertEqual(dataPoint.getRainColour(), Constants.graphColours["clear-day"]!)

        dataPoint.icon = nil
        XCTAssertEqual(dataPoint.getRainColour(), UIColor(white: 1.0, alpha: 0.1))
    }

    func testGetIntensityRange() {
        let dataPoint = DataPoint(object: self.inputJSON as NSDictionary)
        let low = dataPoint.getIntensityRange(precipIntensity: 0.0)
        let medium = dataPoint.getIntensityRange(precipIntensity: 0.05)
        let high = dataPoint.getIntensityRange(precipIntensity: 0.5)

        XCTAssertEqual(low, 1)
        XCTAssertEqual(medium, 2)
        XCTAssertEqual(high, 3)
    }
}
