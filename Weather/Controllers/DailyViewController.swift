//
//  DailyTableViewController.swift
//  Weather
//
//  Created by James Shaw on 17/06/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import WeatherFrontKit

protocol DailyViewControllerDelegate {
    func didSelectRow(expand: Bool)
}

class DailyViewController: UIViewController {

    var delegate: DailyViewControllerDelegate?
    
    // Daily dataPoints
    var dataPoints:[DataPoint]? {
        didSet {
            self.reloadDataPoints()
        }
    }

    var hourlyDataPoints:[[DataPoint]]?

    var minTemp: CGFloat = 0.0
    var maxTemp: CGFloat = 0.0

    @IBOutlet var tableView: UITableView!

    var expandedRowIndexes:[Int] = []
    var timeZoneString: String?
    var noDailyForecastLabel: UILabel!
    
    override func viewDidLoad() {
        
        // Initalise UITableView
        self.tableView.isScrollEnabled = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        //------------
        
        // Clear background
        self.view.backgroundColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear
        //-------------
        
        // Create no daily forecast label
        self.noDailyForecastLabel = UILabel(frame: CGRect.zero)
        self.noDailyForecastLabel.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.thin)
        self.noDailyForecastLabel.textColor = UIColor.white
        self.noDailyForecastLabel.text = "Unable to fetch daily forecast."
        self.noDailyForecastLabel.sizeToFit()
        //-------------
    }
    
    func reloadDataPoints() {
        if self.dataPoints != nil {
            DispatchQueue.main.async {
                if self.tableView.subviews.contains(self.noDailyForecastLabel) {
                    self.noDailyForecastLabel.removeFromSuperview()
                }
                
                self.tableView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.noDailyForecastLabel.center = CGPoint(x: self.tableView.center.x, y: 29.0)
                self.tableView.addSubview(self.noDailyForecastLabel)
            }
        }
        
    }

    // Method compares the date of the cell, with the date of all hourly dataPoints
    // Returns hourlyDataPoints that are in the day of the cell
    func getHourlyDataPointsForCell(_ hourlyDataPoints: [DataPoint], dailyDataPoint: DataPoint) -> [DataPoint] {

        var cellDataPoints:[DataPoint] = []
        
        if let time = dailyDataPoint.time {

            let dayDate = UnixTimeManager.calculateTimeFromUnix(seconds: time, dateFormat: "yyyy-MM-dd", timeZoneString: self.timeZoneString)
            
            // Filter hourly data points so the hourly 'date' and day 'date' are the same
            cellDataPoints = hourlyDataPoints.filter { UnixTimeManager.calculateTimeFromUnix(seconds: $0.time!, dateFormat: "yyyy-MM-dd", timeZoneString: self.timeZoneString) == dayDate }
        }

        return cellDataPoints
    }
}

extension DailyViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataPoints = self.dataPoints {
            return dataPoints.count - 1 // Exclude the last daily so we have 7 day, not 8 day forecast
        } else {
            return 0
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if self.expandedRowIndexes.contains((indexPath as NSIndexPath).row) {
            return 120.0
        }

        return 70.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let celsius = SettingsManager.isCelsius()

        var cell = tableView.dequeueReusableCell(withIdentifier: "dailyTableViewCell") as? DailyTableViewCell
        if cell == nil {
            cell = DailyTableViewCell.init(style: .default, reuseIdentifier: "dailyTableViewCell")
        }

        cell!.selectionStyle = .none

        guard let dailyDataPoints = self.dataPoints else {
            return cell!
        }

        DispatchQueue.main.async {
            cell!.summaryView.alpha = cell!.summaryShowing ? 1.0 : 0.0
            cell!.todayForecastView.alpha = cell!.summaryShowing ? 0.0 : 1.0
        }

        var day = "n/a"
        if let time = dailyDataPoints[(indexPath as NSIndexPath).row].time {
            day = UnixTimeManager.calculateDayFromUnix(seconds: time, timeZoneString: self.timeZoneString)
        }
        DispatchQueue.main.async {
            cell!.dayLabel.text = day
        }

        if let maxTemperature = dailyDataPoints[(indexPath as NSIndexPath).row].dailyMaxTemperature {
            if let minTemperature = dailyDataPoints[(indexPath as NSIndexPath).row].dailyMinTemperature {
                if celsius == true {
                    let celsiusMaxTemp = UnitManager.celsius(fahrenheit: maxTemperature)
                    let celsiusMinTemp = UnitManager.celsius(fahrenheit: minTemperature)
                    cell!.maxTempLabel.text = "\(Int(celsiusMaxTemp))°"
                    cell!.minTempLabel.text = "\(Int(celsiusMinTemp))°"
                } else {
                    cell!.maxTempLabel.text = "\(Int(maxTemperature))°"
                    cell!.minTempLabel.text = "\(Int(minTemperature))°"
                }
            }
        }

        if let hourlyDataPoints = self.hourlyDataPoints {
            cell!.todayForecastView.backgroundThreadComplete = false
            cell!.summaryHourlyView.dataPoints = hourlyDataPoints[(indexPath as NSIndexPath).row]
            cell!.todayForecastView.dataPoints = hourlyDataPoints[(indexPath as NSIndexPath).row]

            if let timeZone = self.timeZoneString {
                cell!.todayForecastView.timeZoneString = timeZone
            }
        }
        else {
            cell!.todayForecastView.dataPoints = nil
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let _ = self.dataPoints else {
            return
        }

        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }

        var expand = false
        let cell = tableView.cellForRow(at: indexPath) as! DailyTableViewCell
        if self.expandedRowIndexes.contains((indexPath as NSIndexPath).row) {

            // Remove this row from expanded rows
            if let index = self.expandedRowIndexes.index(of: (indexPath as NSIndexPath).row) {
                self.expandedRowIndexes.remove(at: index)

                // TableView is shrinking
                expand = false
            }
        }
        else {
            self.expandedRowIndexes.append((indexPath as NSIndexPath).row)

            // TableView is expanding
            expand = true
        }

        self.delegate?.didSelectRow(expand: expand)

        // Fade animation
        UIView.animate(withDuration: 0.5, animations: {
            cell.summaryView.alpha = cell.summaryShowing ? 0.0 : 1.0
            cell.todayForecastView.alpha = cell.summaryShowing ? 1.0 : 0.0
        })

        cell.summaryShowing = !cell.summaryShowing
        cell.todayForecastView.summaryShowing = !cell.todayForecastView.summaryShowing

        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
