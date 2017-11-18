//
//  UnixTimeManagerTests.swift
//  WeatherTests
//
//  Created by James Shaw on 04/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import XCTest
@testable import WeatherFrontKit

class UnixTimeManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCalculateTimeFromUnix() {
        let timeZone = "Europe/London"
        let seconds = 1509775921
        let dateFormat = "hh:mm"

        let timeString = UnixTimeManager.calculateTimeFromUnix(seconds: seconds, dateFormat: dateFormat, timeZoneString: timeZone)
        XCTAssertEqual(timeString, "06:12")
    }

    func testCalculateDayFromUnixToday() {
        let timeZone = "Europe/London"
        let seconds = Int(Date().timeIntervalSince1970)

        let dayString = UnixTimeManager.calculateDayFromUnix(seconds: seconds, timeZoneString: timeZone)
        XCTAssertEqual(dayString, "Today")
    }

    func testCalculateDayFromUnixTomorrow() {
        let timeZone = "Europe/London"
        let tomorrow: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: Date(), options:[])!
        let seconds = Int(tomorrow.timeIntervalSince1970)

        let dayString = UnixTimeManager.calculateDayFromUnix(seconds: seconds, timeZoneString: timeZone)
        XCTAssertEqual(dayString, "Tomorrow")
    }

    func testCalculateDayFromUnixMonday() {
        let timeZone = "Europe/London"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let saturday = dateFormatter.date(from: "04/11/2017") else { return }
        let sunday: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: saturday, options:[])!
        let seconds = Int(sunday.timeIntervalSince1970)

        let dayString = UnixTimeManager.calculateDayFromUnix(seconds: seconds, timeZoneString: timeZone)
        XCTAssertEqual(dayString, "Sunday")
    }

    func testTimeIsTodayFalse() {
        let timeZone = "Europe/London"
        let futureDate: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: 20, to: Date(), options:[])!
        let seconds = Int(futureDate.timeIntervalSince1970)

        let timeIsToday = UnixTimeManager.timeIsToday(seconds: seconds, timeZone: timeZone)
        XCTAssertEqual(timeIsToday, false)
    }

    func testTimeIsTodayTrue() {
        let timeZone = "Europe/London"
        let seconds = Int(Date().timeIntervalSince1970)

        let timeIsToday = UnixTimeManager.timeIsToday(seconds: seconds, timeZone: timeZone)
        XCTAssertEqual(timeIsToday, true)
    }

    func testCalculateTimeFromUnixWithoutDateFormat() {
        let timeZone = "Europe/London"
        let seconds = 1509775921

        let timeString = UnixTimeManager.calculateTimeFromUnix(seconds: seconds, timeZoneString: timeZone)
        XCTAssertEqual(timeString, "6AM")
    }

    func testCalculateTimeFromUnixNowWithoutDateFormat() {
        let timeZone = "Europe/London"
        let seconds = Int(Date().timeIntervalSince1970)

        let dayString = UnixTimeManager.calculateTimeFromUnix(seconds: seconds, timeZoneString: timeZone)
        XCTAssertEqual(dayString, "Now")
    }
}
