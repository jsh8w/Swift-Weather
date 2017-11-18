//
//  DownloadManager.swift
//  Weather
//
//  Created by James Shaw on 21/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import Foundation
import UIKit

open class DownloadManager: NSObject {
    
    open static let shared = DownloadManager()

    var task: URLSessionDataTask?
    let dispatchGroup = DispatchGroup()

    var forecastDataDict:[Int: Data] = [:]
    
    open func downloadData(latitude: Float, longitude: Float, forecast: Forecast) {

        self.forecastDataDict = [:]
        
        // 7 days
        for index in 0...6 {
            if index == 0 {
                // Normal forecast call for Today
                self.forecastCall(latitude: latitude, longitude: longitude, index: index, forecast: forecast)

            } else {
                // Time machine call for remaining days
                
                let tomorrowTime = Int(Date().timeIntervalSince1970 + Double(86400 * index))
                self.timeMachineCall(latitude: latitude, longitude: longitude, time: tomorrowTime, index: index, forecast: forecast)
            }
        }
        
        // Called when all time machine calls are complete
        self.dispatchGroup.notify(queue: DispatchQueue.main) {
            var dataArray:[Data] = []
            let sortedTupleArray = self.forecastDataDict.sorted { $0.0 < $1.0 }
            for tuple in sortedTupleArray {
                dataArray.append(tuple.1)
            }

            if dataArray.count == 7 {
                self.parseforecastDataDict(dataArray: dataArray, forecast: forecast)
            } else {
                NotificationCenter.default.post(name: Constants.Notifications.downloadForecastFailed, object: self, userInfo: nil)
            }
        }
    }

    open func downloadWidgetData(latitude: Float, longitude: Float, forecast: Forecast) {
        self.forecastCall(latitude: latitude, longitude: longitude, index: 0, forecast: forecast)

        self.dispatchGroup.notify(queue: .main) {

            var dataArray:[Data] = []
            let sortedTupleArray = self.forecastDataDict.sorted { $0.0 < $1.0 }
            for tuple in sortedTupleArray {
                dataArray.append(tuple.1)
            }

            self.parseforecastDataDict(dataArray: dataArray, forecast: forecast)
        }
    }
    
    func forecastCall(latitude: Float, longitude: Float, index: Int, forecast: Forecast) {

        let urlString = "\(Constants.darkSkyAPIUrl)\(latitude),\(longitude)"
        let url = URL(string: urlString)!

        self.dispatchGroup.enter()
        self.task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error -> Void in

            guard error == nil, let returnedData = data else {
                if let error = error, error._code != -999 {
                    // if error is not "cancelled"
                    NotificationCenter.default.post(name: Constants.Notifications.downloadForecastFailed, object: self, userInfo: nil)
                }
                return
            }

            self.forecastDataDict[index] = returnedData

            self.dispatchGroup.leave()

        })
        self.task?.resume()

    }
    
    open func stopDownloadTask() {
        self.task?.cancel()
    }
    
    func timeMachineCall(latitude: Float, longitude: Float, time: Int, index: Int, forecast: Forecast) {

        let urlString = "\(Constants.darkSkyAPIUrl)\(latitude),\(longitude),\(time)"
        let url = URL(string: urlString)!

        self.dispatchGroup.enter()
        self.task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error -> Void in

            guard error == nil, let returnedData = data else {
                if let error = error, error._code != -999 {
                    // if error is not "cancelled"
                    NotificationCenter.default.post(name: Constants.Notifications.downloadForecastFailed, object: self, userInfo: nil)
                }
                return
            }

            self.forecastDataDict[index] = returnedData

            self.dispatchGroup.leave()

        })
        self.task?.resume()
    }
    
    func parseforecastDataDict(dataArray: [Data], forecast: Forecast) {
        
        // Loop through each data
        for (index, data) in dataArray.enumerated() {
        
            do {
                let parsedObject: Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                if let object = parsedObject as? NSDictionary {

                    if index == 0 {
                        // Today call
                        if let latitude = object["latitude"] as? Float,
                            let longitude = object["longitude"] as? Float,
                            let timezone = object["timezone"] as? String {

                            forecast.latitude = latitude
                            forecast.longitude = longitude
                            forecast.timezone = timezone
                            
                            if let currently = object["currently"] as? NSDictionary {
                                let currentlyDataPoint = DataPoint(object: currently)
                                forecast.currently = currentlyDataPoint
                            }

                            if let minutely = object["minutely"] as? NSDictionary {
                                let minutelyDataBlock = DataBlock(object: minutely, isHourly: false, timeZone: timezone)
                                forecast.minutely = minutelyDataBlock
                            }

                            if let hourly = object["hourly"] as? NSDictionary {
                                let hourlyDataBlock = DataBlock(object: hourly, isHourly: true, timeZone: timezone)
                                forecast.hourly = hourlyDataBlock
                            }

                            if let daily = object["daily"] as? NSDictionary {
                                let dailyDataBlock = DataBlock(object: daily, isHourly: false, timeZone: timezone)
                                forecast.daily = dailyDataBlock
                            }
                        }
                    } else {
                        // Time machine call
                    
                        // Create the 'Hourly' DataBlock
                        if let hourly = object["hourly"] as? NSDictionary, let data = hourly["data"] as? NSArray {
                            var hourlyDataPoints:[DataPoint] = []

                            for dataPointObject in data {
                                if let dataPointDict = dataPointObject as? NSDictionary {
                                    let dataPoint = DataPoint(object: dataPointDict)
                                    hourlyDataPoints.append(dataPoint)
                                }
                            }

                            forecast.hourly?.hourlyDataPoints?.append(hourlyDataPoints)
                        }
                    }
                }
            } catch let error as NSError {
                print("A JSON parsing error occurred, here are the details:\n \(error)")
                
                NotificationCenter.default.post(name: Constants.Notifications.downloadForecastFailed, object: self, userInfo: nil)
                return
            }
        }

        var notificationDict:[String: Forecast] = [:]
        notificationDict["forecast"] = forecast
        NotificationCenter.default.post(name: Constants.Notifications.downloadForecastComplete, object: self, userInfo: notificationDict)
    }
}
