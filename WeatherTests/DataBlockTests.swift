//
//  DataBlockTests.swift
//  WeatherTests
//
//  Created by James Shaw on 04/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import XCTest
@testable import WeatherFrontKit

class DataBlockTests: XCTestCase {

    var inputJSON: [String: Any] = [:]
    var dataPointJSON: [String: Any] = [:]

    override func setUp() {
        super.setUp()

        self.dataPointJSON = [
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

        self.inputJSON["summary"] = "Light rain until this evening."
        self.inputJSON["icon"] = "rain"
        self.inputJSON["data"] = [self.dataPointJSON]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        let dataBlock = DataBlock(object: self.inputJSON as NSDictionary, isHourly: false, timeZone: "Europe/London")
        let dataPoint = DataPoint(object: self.dataPointJSON as NSDictionary)

        XCTAssertEqual(dataBlock.summary, "Light rain until this evening.")
        XCTAssertEqual(dataBlock.icon, "rain")

        guard let firstDataPointTime = dataBlock.dataPoints?.first?.time else {
            return
        }

        XCTAssertEqual(firstDataPointTime, dataPoint.time)
    }
}
