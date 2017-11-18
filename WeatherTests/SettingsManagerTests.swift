//
//  SettingsManagerTests.swift
//  WeatherTests
//
//  Created by James Shaw on 29/10/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import XCTest
@testable import WeatherFrontKit

class SettingsManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        SettingsManager.setup()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetTemperatureCelsius() {
        SettingsManager.setTemperature(celsius: true)

        let celsius = SettingsManager.isCelsius()
        XCTAssertTrue(celsius)
    }

    func testSetSpeedMPH() {
        SettingsManager.setSpeed(mph: true)

        let mph = SettingsManager.isMPH()
        XCTAssertTrue(mph)
    }

    func testSetPageIndex() {
        SettingsManager.setPageIndex(index: 1)

        let pageIndex = SettingsManager.pageIndex()
        XCTAssertEqual(pageIndex, 1)
    }

    func testSetWidgetExpanded() {
        SettingsManager.setWidgetExpanded(expanded: true)

        let widgetExpanded = SettingsManager.widgetExpanded()
        XCTAssertTrue(widgetExpanded)
    }
}
