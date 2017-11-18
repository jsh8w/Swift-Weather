//
//  UnixTimeManager.swift
//  Weather
//
//  Created by James Shaw on 04/11/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

open class UnixTimeManager: NSObject {

    open class func calculateTimeFromUnix(seconds: Int, dateFormat: String, timeZoneString: String?) -> String {

        let date = Date(timeIntervalSince1970: Double(seconds))
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat // e.g "hh:mm"

        if let timeZoneString = timeZoneString {
            if TimeZone.knownTimeZoneIdentifiers.contains(timeZoneString) {
                formatter.timeZone = TimeZone(identifier: timeZoneString)
            } else {
                formatter.timeZone = TimeZone.autoupdatingCurrent
            }
        } else {
            formatter.timeZone = TimeZone.autoupdatingCurrent
        }

        let localTimeString = formatter.string(from: date)
        return localTimeString
    }

    open class func calculateDayFromUnix(seconds: Int, timeZoneString: String?) -> String {

        let date = Date(timeIntervalSince1970: Double(seconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let timeZoneString = timeZoneString {
            if TimeZone.knownTimeZoneIdentifiers.contains(timeZoneString) {
                formatter.timeZone = TimeZone(identifier: timeZoneString)
            } else {
                formatter.timeZone = TimeZone.autoupdatingCurrent
            }
        } else {
            formatter.timeZone = TimeZone.autoupdatingCurrent
        }

        var localTimeString = formatter.string(from: date)
        let currentTimeString = formatter.string(from: Date())
        if localTimeString == currentTimeString {
            return "Today"
        }

        let tomorrow: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: Date(), options:[])!
        let tomorrowTimeString = formatter.string(from: tomorrow)
        if localTimeString == tomorrowTimeString {
            return "Tomorrow"
        }

        formatter.dateFormat = "cccc"
        localTimeString = formatter.string(from: date)
        return localTimeString
    }

    open class func timeIsToday(seconds: Int, timeZone: String) -> Bool {

        let date = Date(timeIntervalSince1970: Double(seconds + 1))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if TimeZone.knownTimeZoneIdentifiers.contains(timeZone) {
            formatter.timeZone = TimeZone(identifier: timeZone)
        } else {
            formatter.timeZone = TimeZone.autoupdatingCurrent
        }

        let localTimeString = formatter.string(from: date)
        let currentTimeString = formatter.string(from: Date())

        if localTimeString == currentTimeString {
            return true
        }

        return false
    }

    open class func calculateTimeFromUnix(seconds: Int, timeZoneString: String?) -> String {

        let date = Date(timeIntervalSince1970: Double(seconds))
        let formatter = DateFormatter()
        let dateFormat: String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale: Locale.current)!
        if dateFormat.contains("a") {
            // 12 hour clock
            formatter.dateFormat = "ha"
        } else {
            // 24 hour clock
            formatter.dateFormat = "HH:mm"
        }
        formatter.locale = Locale.current

        if let timeZone = timeZoneString {
            if TimeZone.knownTimeZoneIdentifiers.contains(timeZone) {
                formatter.timeZone = TimeZone(identifier: timeZone)
            } else {
                formatter.timeZone = TimeZone.autoupdatingCurrent
            }
        } else {
            formatter.timeZone = TimeZone.autoupdatingCurrent
        }

        let localTimeString = formatter.string(from: date)

        if self.timeIsNow(date: date, timeZoneString: timeZoneString) == true {
            return "Now"
        }

        return localTimeString
    }

    private class func timeIsNow(date: Date, timeZoneString: String?) -> Bool {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH"

        if let timeZone = timeZoneString {
            if TimeZone.knownTimeZoneIdentifiers.contains(timeZone) {
                formatter.timeZone = TimeZone(identifier: timeZone)
            }
            else {
                formatter.timeZone = TimeZone.autoupdatingCurrent
            }
        } else {
            formatter.timeZone = TimeZone.autoupdatingCurrent
        }

        let localTimeString = formatter.string(from: date)
        let currentTimeString = formatter.string(from: Date())
        if localTimeString == currentTimeString {
            return true
        }

        return false
    }
}
