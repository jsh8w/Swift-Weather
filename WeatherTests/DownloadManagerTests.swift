//
//  DownloadManagerTests.swift
//  WeatherTests
//
//  Created by James Shaw on 04/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import XCTest
@testable import WeatherFrontKit
@testable import Weather

class DownloadManagerTests: XCTestCase {

    var data:[Data] = []
    var forecast: Forecast!
    
    override func setUp() {
        super.setUp()

        guard let jsonPath = Bundle.main.path(forResource: "forecast1", ofType: "json") else { return }
        guard let jsonData = NSData(contentsOfFile: jsonPath) else { return }
        self.data.append(jsonData as Data)

        self.forecast = Forecast()
    }
    
    override func tearDown() {
        self.forecast = nil
        self.data = []

        super.tearDown()
    }

    func testParse() {
        DownloadManager.shared.parseforecastDataDict(dataArray: self.data, forecast: self.forecast)

        XCTAssertEqual(self.forecast.latitude, 48.8566)
        XCTAssertEqual(self.forecast.longitude, 2.3522)
        XCTAssertEqual(self.forecast.timezone, "Europe/Paris")
        XCTAssertEqual(self.forecast.currently?.time, 1470144608)
        XCTAssertEqual(self.forecast.hourly?.summary, "Light rain until this evening.")
    }
}
