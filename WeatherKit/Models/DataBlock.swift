//
//  DataBlock.swift
//  Weather
//
//  Created by James Shaw on 19/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//


// This class represents the weather over a period of time.

import UIKit

open class DataBlock: NSObject {
    
    // Summary of this data block e.g Drizzle starting in 11 mins, stopping 6 mins later.
    open var summary: String?
    
    // Text summary of data block that can be used for icon
    open var icon: String?
    
    // Data Points for each period in time
    open var dataPoints: [DataPoint]?
    
    // Data Points for each period in time
    open var hourlyDataPoints: [[DataPoint]]?

    public init(object: NSDictionary, isHourly: Bool, timeZone: String) {

        if let summary = object["summary"] as? String,
            let icon = object["icon"] as? String {

            self.summary = summary
            self.icon = icon

            if let data = object["data"] as? NSArray {
                var dataPoints: [DataPoint] = []

                for dataPointObject in data {
                    if let dataPointDict = dataPointObject as? NSDictionary {
                        let dataPoint = DataPoint(object: dataPointDict)

                        if isHourly {
                            if let time = dataPoint.time {
                                if UnixTimeManager.timeIsToday(seconds: time, timeZone: timeZone) {
                                    dataPoints.append(dataPoint)
                                }
                            }
                        } else {
                            dataPoints.append(dataPoint)
                        }
                    }
                }

                if isHourly {
                    self.hourlyDataPoints = [dataPoints]
                } else {
                    self.dataPoints = dataPoints
                }
            }
        }
    }
}
