//
//  LocationViewController+Drawing.swift
//  Weather
//
//  Created by James Shaw on 08/10/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit
import WeatherFrontKit

extension LocationViewController {

    // MARK: Drawing Code

    func drawView() {

        // Create UIView to darken the bottom part UIPageControl dots
        let darkPageControlView = UIView(frame: CGRect(x: 0.0, y: self.view.frame.height - self.bottomBorder, width: self.view.frame.width, height: self.bottomBorder))
        darkPageControlView.backgroundColor = UIColor.black
        darkPageControlView.alpha = 0.3

        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(darkPageControlView)
        })
        //--------------

        // Y coordinate to draw next at
        var y: CGFloat = self.topBorder + 8.0
        let xMargin: CGFloat = 8.0

        // Draw location label
        self.locationLabel = UILabel(frame: CGRect(x: xMargin, y: y, width: self.view.frame.width - (2.0 * xMargin), height: 22.0))
        self.locationLabel.textColor = UIColor.white
        self.locationLabel.textAlignment = .center
        self.locationLabel.adjustsFontSizeToFitWidth = true
        DispatchQueue.main.async(execute: { () -> Void in
            if let displayName = self.displayName {
                self.locationLabel.text = displayName
            }
            self.view.addSubview(self.locationLabel)
        })
        //------------

        y += self.locationLabel.frame.height

        // Draw summary label
        self.summaryLabel = UILabel(frame: CGRect(x: xMargin, y: y + 4.0, width: self.locationLabel.frame.width, height: 28.0))
        self.summaryLabel.textColor = UIColor.white
        self.summaryLabel.textAlignment = .center
        self.summaryLabel.adjustsFontSizeToFitWidth = true
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(self.summaryLabel)
        })
        //------------

        y += self.summaryLabel.frame.height + 4.0

        // Draw top area of view
        y = self.drawHeaderView()
        self.maskStartingY = y
        self.maskMaxTravellingDistance = y - (self.summaryLabel.frame.origin.y + self.summaryLabel.frame.height)

        // Setup UIScrollView
        self.scrollView = UIScrollView(frame: CGRect(x: 0.0, y: self.topBorder, width: self.view.frame.width, height: self.view.frame.height - self.topBorder - self.bottomBorder - 1.0))
        self.scrollView.delegate = self
        self.scrollView.bounces = true
        self.scrollView.isScrollEnabled = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.backgroundColor = UIColor.clear
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(self.scrollView)
        })
        //--------------

        // Draw Mask
        self.maskView = UIView(frame: CGRect(x: 0.0, y: self.maskStartingY, width: self.scrollView.frame.width, height: self.view.frame.height - self.maskStartingY - self.bottomBorder))
        self.maskView.backgroundColor = UIColor.clear
        self.maskView.clipsToBounds = true
        DispatchQueue.main.async(execute: { () -> Void in
            self.scrollView.addSubview(self.maskView)
        })
        //--------------

        // Draw content
        y = self.drawContentView()

        // HeaderView disappears so we need to add headerView height + status bar height to the contentSize
        y += self.headerView.frame.height + 20.0

        // Update UIScrollView contentSize once the view is drawn
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: y)

        // Create touchesView to respond to switch between summary and forecastDetailsView
        self.touchesView = UIView(frame: self.summaryView.frame)
        self.touchesView.isUserInteractionEnabled = true
        self.touchesView.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(detailSummarySwitch))
        self.touchesView.addGestureRecognizer(tap)
        DispatchQueue.main.async(execute: { () -> Void in
            self.scrollView.addSubview(self.touchesView)
        })
        //-------------

    }

    func drawHeaderView() -> CGFloat {

        // Draw headerView
        self.headerView = UIView(frame: CGRect(x: 0.0, y: self.topBorder, width: self.view.frame.width, height: 100.0))
        self.headerView.backgroundColor = UIColor.clear
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(self.headerView)
        })
        //----------

        // Add line at the bottom of the view
        let lineY = self.view.frame.height * 0.33
        self.bottomLineView = UIView(frame: CGRect(x: 0.0, y: lineY, width: self.headerView.frame.width, height: 0.5))
        self.bottomLineView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        DispatchQueue.main.async(execute: { () -> Void in
            self.headerView.addSubview(self.bottomLineView)
        })
        //------------

        // Draw summaryView
        let y: CGFloat = self.summaryLabel.frame.origin.y + self.summaryLabel.frame.height + 8.0 - self.topBorder
        let height = lineY - 8.0 - y
        self.summaryView = UIView(frame: CGRect(x: 0.0, y: y, width: self.headerView.frame.width, height: height))
        self.summaryView.backgroundColor = UIColor.clear
        self.summaryView.alpha = 1.0
        //--------------

        // Add temperatureLabel
        self.temperatureLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.summaryView.frame.width / 2.0, height: self.summaryView.frame.height))
        self.temperatureLabel.textColor = UIColor.white
        self.temperatureLabel.adjustsFontSizeToFitWidth = true
        self.temperatureLabel.textAlignment = .center
        DispatchQueue.main.async(execute: { () -> Void in
            self.summaryView.addSubview(self.temperatureLabel)
        })
        //-----------

        // Add iconLabel
        self.iconLabel = UILabel(frame: CGRect(x: self.summaryView.frame.width / 2.0, y: 0.0, width: self.summaryView.frame.width / 2.0, height: self.summaryView.frame.height))
        self.iconLabel.textColor = UIColor.white
        self.iconLabel.adjustsFontSizeToFitWidth = true
        self.iconLabel.textAlignment = .center
        DispatchQueue.main.async(execute: { () -> Void in
            self.summaryView.addSubview(self.iconLabel)
            self.headerView.addSubview(self.summaryView)
        })
        //------------

        // Set label font sizes depending on screen size
        self.setLabelFontSizes()

        // Draw forecastDetailsView
        self.forecastDetailsView = ForecastDetailsView(frame: self.summaryView.frame)
        self.forecastDetailsView.alpha = 0.0
        DispatchQueue.main.async(execute: { () -> Void in
            self.headerView.addSubview(self.forecastDetailsView)
        })
        //-----------

        // Update HeaderView height
        self.headerView.frame = CGRect(x: 0.0, y: self.topBorder, width: self.view.frame.width, height: lineY + 1.0 - self.topBorder)

        // Draw prompt
        self.detailSummaryPrompt = UILabel(frame: CGRect.zero)
        self.detailSummaryPrompt.font = UIFont(name: "FontAwesome", size: 20.0)
        self.detailSummaryPrompt.text = Constants.fontAwesomeCodes["fa-angle-up"]
        self.detailSummaryPrompt.textColor = UIColor.white
        self.detailSummaryPrompt.sizeToFit()
        self.detailSummaryPrompt.center = CGPoint(x: self.headerView.center.x, y: self.bottomLineView.frame.origin.y - 10.0)
        self.headerView.addSubview(self.detailSummaryPrompt)
        //-------------

        return lineY + 1.0

    }

    func drawContentView() -> CGFloat {

        // Y coordinate to draw next at
        var y: CGFloat = 0.0

        // Draw Content View
        self.contentView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.maskView.frame.width, height: 100.0))
        self.contentView.backgroundColor = UIColor.clear
        //--------------

        // Draw RainFallGraph
        y = self.drawRainfallGraph(y)

        // Draw UITableView for Daily data
        y = self.drawDailyTableView(y)

        // Draw forecast button
        self.forecastButton = UIButton(frame: CGRect(x: 0.0, y: y + 12.0, width: 150.0, height: 14.0))
        self.forecastButton.addTarget(self, action: #selector(LocationViewController.openSafariForecast(_:)), for: UIControlEvents.touchUpInside)
        self.forecastButton.titleLabel?.textAlignment = .center

        // Create the attributed string
        let poweredAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.7)]
        let forecastAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.7), NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue] as [NSAttributedStringKey : Any]
        let attributedString = NSMutableAttributedString(string: "Powered by ", attributes: poweredAttributes)
        attributedString.append(NSMutableAttributedString(string: "Dark Sky",attributes: forecastAttributes))
        //----------

        self.forecastButton.setAttributedTitle(attributedString, for: UIControlState())
        self.forecastButton.center = CGPoint(x: self.contentView.center.x, y: y + 19.0)
        self.contentView.addSubview(self.forecastButton)
        //-----------

        y += forecastButton.frame.height + 24.0

        // Update height of content view
        self.contentView.frame = CGRect(x: 0.0, y: 0.0, width: self.maskView.frame.width, height: y)

        // Create UIView to darken the content View
        self.darkView = UIView(frame: self.contentView.frame)
        self.darkView.backgroundColor = UIColor.black
        self.darkView.alpha = 0.3
        self.contentView.addSubview(self.darkView)
        self.contentView.sendSubview(toBack: self.darkView)
        //--------------

        // Add contentView to maskView
        self.maskView.addSubview(self.contentView)

        return y

    }

    // Method to draw loading View
    func drawLoadingView() {

        // Create Loading View
        self.loadingView = UIView(frame: self.view.frame)
        self.loadingView.backgroundColor = UIColor.clear
        self.loadingView.alpha = 1.0
        //------------

        // Create Visual Effect View
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.visualEffectView.frame = self.loadingView.bounds
        self.loadingView.addSubview(self.visualEffectView)
        //--------

        // Create Name Label
        self.loadingNameLabel = UILabel(frame: CGRect(x: 8.0, y: self.loadingView.center.y - 30.0 - 6.0, width: self.loadingView.frame.width - 16.0, height: 30.0))
        self.loadingNameLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
        if let displayName = self.displayName {
            self.loadingNameLabel.text = displayName
        }
        self.loadingNameLabel.font = UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.light)
        self.loadingNameLabel.adjustsFontSizeToFitWidth = true
        self.loadingNameLabel.textAlignment = .center
        self.loadingNameLabel.alpha = 1.0
        self.loadingView.addSubview(self.loadingNameLabel)
        //------------

        // Create Label
        self.loadingLabel = UILabel(frame: CGRect.zero)
        self.loadingLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
        self.loadingLabel.text = "Fetching weather data"
        self.loadingLabel.textAlignment = .center
        self.loadingLabel.alpha = 1.0
        if self.isCurrentLocation == true {
            self.loadingLabel.font = UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.thin)
            self.loadingLabel.sizeToFit()
            self.loadingLabel.center = self.loadingView.center
        }
        else {
            self.loadingLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.thin)
            self.loadingLabel.sizeToFit()
            self.loadingLabel.center = CGPoint(x: self.loadingView.center.x, y: self.loadingView.center.y + 12.0 + 6.0)
        }
        self.loadingView.addSubview(self.loadingLabel)
        //------------

        // Create retry button
        self.retryButton = UIButton(type: UIButtonType.custom)
        let buttonWidth: CGFloat = 130.0
        self.retryButton.frame = CGRect(x: (self.loadingView.frame.width / 2) - (buttonWidth / 2), y: self.loadingLabel.frame.origin.y + self.loadingLabel.frame.height + 30.0, width: buttonWidth, height: 35.0)
        self.retryButton.setTitle("Retry", for: UIControlState())
        self.retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight.thin)
        self.retryButton.alpha = 0.0
        self.retryButton.isEnabled = false
        self.retryButton.addTarget(self, action: #selector(LocationViewController.retryButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.retryButton.backgroundColor = UIColor.clear
        self.retryButton.layer.cornerRadius = 5
        self.retryButton.layer.borderWidth = 1
        self.retryButton.layer.borderColor = UIColor.white.cgColor
        self.loadingView.addSubview(self.retryButton)
        //-----------
    }

    func drawRainfallGraph(_ y: CGFloat) -> CGFloat {

        let graphHeight: CGFloat = self.setRainfallGraphHeight()

        self.rainGraphView = RainGraphView(frame: CGRect(x: 0.0, y: y + 1.0, width: self.contentView.frame.width, height: graphHeight))
        DispatchQueue.main.async {
            self.contentView.addSubview(self.rainGraphView)
        }

        // Update yCoordinate
        let yCoordinate = y + graphHeight + 1.0

        return yCoordinate

    }

    func drawDailyTableView(_ y: CGFloat) -> CGFloat {

        let noOfCells = 7
        let heightOfCell = 70.0
        let tableViewHeight = CGFloat(noOfCells) * CGFloat(heightOfCell)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.dailyViewController = storyboard.instantiateViewController(withIdentifier: "dailyViewController") as! DailyViewController
        self.dailyViewController.delegate = self
        self.dailyViewController.view.frame.origin = CGPoint(x: 0.0, y: y)
        self.contentView.addSubview(self.dailyViewController.view)
        self.addChildViewController(self.dailyViewController)

        let yCoordinate = y + tableViewHeight

        return yCoordinate
    }

    func updateViewWithForecast() {

        let celsius = SettingsManager.isCelsius()
        let mph = SettingsManager.isMPH()

        if let timezone = self.forecast.timezone {
            self.dailyViewController.timeZoneString = timezone
        }

        // Icon
        var iconCode = Constants.forecastIcons["no-report"]!
        if let icon = self.forecast.currently?.icon {
            iconCode = Constants.forecastIcons[icon]!
        }
        DispatchQueue.main.async {
            self.iconLabel.text = "\(iconCode)"
        }
        //-----------

        // Temperature
        var temperatureString = "n/a"
        if let temperature = self.forecast.currently?.temperature {
            if celsius == true {
                let celsiusTemp = UnitManager.celsius(fahrenheit: temperature)
                temperatureString = "\(Int(celsiusTemp))°"
            } else {
                temperatureString = "\(Int(temperature))°"
            }
        }
        DispatchQueue.main.async {
            self.temperatureLabel.text = temperatureString
        }
        //-----------

        // Summary
        var summaryString = "Summary not available."
        if let summary = self.forecast.currently?.summary {
            summaryString = summary
        }
        DispatchQueue.main.async {
            self.summaryLabel.text = summaryString
        }
        //----------------

        // Feels Like Temperature
        var feelsLikeString = "n/a"
        if let feelsLike = self.forecast.currently?.apparentTemperature {
            if celsius == true {
                let celsiusTemp = UnitManager.celsius(fahrenheit: feelsLike)
                feelsLikeString = "\(Int(celsiusTemp))°"
            } else {
                feelsLikeString = "\(Int(feelsLike))°"
            }
        }
        DispatchQueue.main.async {
            self.forecastDetailsView.feelsLikeValuelabel.text = feelsLikeString
        }
        //------------

        // Precipitation
        var precipitationString = "n/a"
        if let precipitation = self.forecast.currently?.precipProbability {
            let percentage = precipitation * 100
            precipitationString = "\(Int(percentage))%"
        }
        DispatchQueue.main.async {
            self.forecastDetailsView.precipitationValuelabel.text = precipitationString
        }
        //------------

        // Dew Point
        var dewPointString = "n/a"
        if let dewPoint = self.forecast.currently?.dewPoint {
            if celsius == true {
                let celsiusTemp = UnitManager.celsius(fahrenheit: dewPoint)
                dewPointString = "\(Int(celsiusTemp))°"
            } else {
                dewPointString = "\(Int(dewPoint))°"
            }
        }
        DispatchQueue.main.async {
            self.forecastDetailsView.dewPointValuelabel.text = dewPointString
        }
        //------------

        // Humidity
        var humidityString = "n/a"
        if let humidity = self.forecast.currently?.humidity {
            let percentage = humidity * 100
            humidityString = "\(Int(percentage))%"
        }
        DispatchQueue.main.async {
            self.forecastDetailsView.humidityValuelabel.text = humidityString
        }
        //------------

        // Sunrise Time
        var sunriseString = "n/a"
        if let sunrise = self.forecast.daily?.dataPoints?[0].sunriseTime {
            let time = UnixTimeManager.calculateTimeFromUnix(seconds: sunrise, dateFormat: "HH:mm", timeZoneString: self.forecast.timezone)
            sunriseString = "\(time)"
        }
        DispatchQueue.main.async {
            self.forecastDetailsView.sunriseValuelabel.text = sunriseString
        }
        //------------

        // Sunset Time
        var sunsetString = "n/a"
        if let sunset = self.forecast.daily?.dataPoints?[0].sunsetTime {
            let time = UnixTimeManager.calculateTimeFromUnix(seconds: sunset, dateFormat: "HH:mm", timeZoneString: self.forecast.timezone)
            sunsetString = "\(time)"
        }
        DispatchQueue.main.async {
            self.forecastDetailsView.sunsetValuelabel.text = sunsetString
        }
        //------------

        // Cloud Cover
        var cloudCoverString = "n/a"
        if let cloudCover = self.forecast.currently?.cloudCover {
            let percentage = cloudCover * 100
            cloudCoverString = "\(Int(percentage))%"
        }
        DispatchQueue.main.async {
            self.forecastDetailsView.cloudCoverValuelabel.text = cloudCoverString
        }
        //------------

        // Wind
        if let windSpeed = self.forecast.currently?.windSpeed {

            // mph or kph
            var windSpeedCalc = windSpeed
            if mph == false {
                windSpeedCalc = UnitManager.kph(mph: windSpeed)
            }

            // if direction exists
            if let windDirection = self.forecast.currently?.windDirection {
                let direction = self.calculateWindDirection(windDirection)

                let speedAttributes = [NSAttributedStringKey.font: self.forecastDetailsView.windlabel.font, NSAttributedStringKey.foregroundColor: UIColor.white] as [NSAttributedStringKey : Any]
                let directionFont = UIFont.systemFont(ofSize: self.forecastDetailsView.windlabel.font.pointSize - 4.0, weight: UIFont.Weight.thin)
                let directionAttributes = [NSAttributedStringKey.font: directionFont, NSAttributedStringKey.foregroundColor: UIColor.white]
                let attributedString = NSMutableAttributedString(string: "\(Int(windSpeedCalc))", attributes: speedAttributes)
                attributedString.append(NSMutableAttributedString(string: "\(direction)", attributes: directionAttributes))

                DispatchQueue.main.async {
                    self.forecastDetailsView.windValuelabel.attributedText = attributedString
                }
            }
            else {
                DispatchQueue.main.async {
                    self.forecastDetailsView.windValuelabel.text = "\(Int(windSpeedCalc))"
                }
            }
        } else {
            self.forecastDetailsView.windValuelabel.text = "n/a"
        }
        //----------

        // Minutely Precipitation Data
        if let minutelyDataPoints = self.forecast.minutely?.dataPoints {

            var precipPoints:[Float] = []
            var precipBool: Bool = false

            // Get each dataPoint in the hour
            for dataPoint in minutelyDataPoints {
                if let precip = dataPoint.precipIntensity {
                    precipPoints.append(precip)

                    // Check if there is any rain
                    if precip != 0.0 {
                        precipBool = true
                    }
                }
            }

            self.rainGraphView.graphPoints = precipPoints
            self.rainGraphView.minutelyAvailable = true

            DispatchQueue.main.async {
                self.rainGraphView.noPrecipLabel.text = "No Precipitation forecast this hour."

                if precipBool == false {
                    self.rainGraphView.noPrecipLabel.isHidden = false
                } else {
                    self.rainGraphView.noPrecipLabel.isHidden = true
                }
            }
        } else {
            self.rainGraphView.minutelyAvailable = false
            self.rainGraphView.graphPoints = []

            self.rainGraphView.noPrecipLabel.text = "Precipitation data not available."
            self.rainGraphView.noPrecipLabel.isHidden = false
        }
        //--------------

        // Give DailyViewController the forecast and reload data
        if let dailyDataPoints = self.forecast.daily?.dataPoints {
            self.dailyViewController.hourlyDataPoints = self.forecast.hourly?.hourlyDataPoints
            self.dailyViewController.dataPoints = dailyDataPoints

            // Min and Max temperatures
            var minTemp: CGFloat = 1000.0
            var maxTemp: CGFloat = 0.0

            // Get max and min temperatures
            for dataPoint in dailyDataPoints {

                // Max temperature
                if let maxDailyTemp = dataPoint.dailyMaxTemperature {

                    // Celsius/Fahrenheit
                    var calcMaxDailyTemp = maxDailyTemp
                    if celsius == true {
                        calcMaxDailyTemp = UnitManager.celsius(fahrenheit: maxDailyTemp)
                    }

                    if CGFloat(calcMaxDailyTemp) > maxTemp {
                        maxTemp = CGFloat(calcMaxDailyTemp)
                    }
                }
                //--------------

                // Min temperature
                if let minDailyTemp = dataPoint.dailyMinTemperature {
                    var calcMinDailyTemp = minDailyTemp
                    if celsius == true {
                        calcMinDailyTemp = UnitManager.celsius(fahrenheit: minDailyTemp)
                    }

                    if CGFloat(calcMinDailyTemp) < minTemp {
                        minTemp = CGFloat(calcMinDailyTemp)
                    }
                }
            }

            // Update UITableView values
            self.dailyViewController.maxTemp = maxTemp
            self.dailyViewController.minTemp = minTemp
        } else {
            self.dailyViewController.dataPoints = nil
        }

        DispatchQueue.main.async {
            self.hideLoadingView()
        }
    }
}
