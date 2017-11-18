//
//  UnitManagerTests.swift
//  WeatherTests
//
//  Created by James Shaw on 10/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import XCTest
@testable import WeatherFrontKit

class UnitManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testKPH() {
        let kph = UnitManager.kph(mph: 1.0)
        XCTAssertEqual(kph, 1.609344)
    }

    func testCelsius() {
        let celsius = UnitManager.celsius(fahrenheit: 32.0)
        XCTAssertEqual(celsius, 0.0)
    }
}
