//
//  HourlyScrollView.swift
//  Weather
//
//  Created by James Shaw on 05/06/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit

open class TodayForecastView: UIView {
    
    // Points to be displayed on the graph
    open var dataPoints:[DataPoint]? {
        didSet {
            self.dataPointsSet()
        }
    }
    
    // X coordinate that cell has currently been drawn at
    var x: CGFloat = 20.0

    var noOfCells = 24

    open var timeZoneString: String?

    var activityIndicator: UIActivityIndicatorView?

    open var backgroundThreadComplete = false
    open var summaryShowing = true
    
    // Indicates if this is drawn in widget or app
    open var isWidget = false
    
    override open func draw(_ rect: CGRect) {
        self.updateCells(frame.width, height: frame.height)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true

        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func dataPointsSet() {
        DispatchQueue.main.async {
            self.backgroundThreadComplete = true
            self.setNeedsDisplay()
        }
    }

    func updateCells(_ width: CGFloat, height: CGFloat) {

        for subview in self.subviews {
            subview.removeFromSuperview()
        }

        self.handleBackgroundThread()

        guard let dataPoints = self.dataPoints else {
            return
        }

        self.x = 19.0
        let cellWidth: CGFloat = round((width - (2 * self.x)) / CGFloat(self.noOfCells))
        self.x = (width - (cellWidth * CGFloat(self.noOfCells))) / 2

        // Indicates how many continuous cells are the same forecast. Needed to draw labels
        var sameWeatherCount = 0
        var previousWeather: String?
        var precipIntensityRange = 0
        var previousPrecipIntensityRange = 0
        var today = false
        var todayFirstCell = false

        for index in 0...(self.noOfCells - 1) {

            let startingIndex = self.noOfCells - dataPoints.count
            let graphHeight = (height / 3.0)
            let startingY = self.center.y - (graphHeight / 2)
            let rect = CGRect(x: self.x, y: startingY, width: cellWidth, height: graphHeight)

            // Before the current time
            if index < startingIndex {
                self.drawGraphFill(index, dataPoint: nil, rect: rect)
            } else {

                let dataPointIndex = index - startingIndex
                let dataPoint = dataPoints[dataPointIndex]

                // Draw graph fill colour
                self.drawGraphFill(index, dataPoint: dataPoint, rect: rect)

                // if we're at the first cell of the 'Today' todayForecastView, need a bigger line
                todayFirstCell = (index == startingIndex && startingIndex > 0) ? true : false
                if todayFirstCell == true { self.drawBigVerticalLine(self.x, graphHeight: graphHeight) }
                today = (startingIndex > 0) ? true : false

                // Check if time label is needed for this cell
                if self.shouldShowTimeLabel(startingIndex: startingIndex, index: index, today: today, todayFirstCell: todayFirstCell) {

                    self.drawAboveBelowVerticalLines(self.x, graphHeight: graphHeight, showTime: true)

                    if let time = dataPoint.time {
                        self.drawTimeLabel(graphHeight: graphHeight, time: time, cellWidth: cellWidth)
                    }

                    if let temperature = dataPoint.temperature {
                        self.drawTemperatureLabel(graphHeight: graphHeight, temperature: temperature, cellWidth: cellWidth)
                    }
                } else {
                    if index != 0 {
                        self.drawAboveBelowVerticalLines(self.x, graphHeight: graphHeight, showTime: false)
                    }
                }

                // Check if previous cell's weather is the same as this weather
                if let previous = previousWeather {

                    let weatherComparison = self.compareWeather(dataPoint: dataPoint, previousRange: previousPrecipIntensityRange, previous: previous, index: index, lastCell: false)
                    precipIntensityRange = weatherComparison.precipIntensityRange

                    if weatherComparison.sameWeather == true {
                        sameWeatherCount += 1
                    } else {

                        let lastCellComparison = self.compareWeather(dataPoint: dataPoint, previousRange: previousPrecipIntensityRange, previous: previous, index: index, lastCell: true)
                        if lastCellComparison.sameWeather == true {
                            sameWeatherCount += 1

                            self.x += cellWidth
                        }

                        // Draw the label
                        self.drawGraphLabel(dataPoints[dataPointIndex-1], dataPointindex: dataPointIndex, cellWidth: cellWidth, sameWeatherCount: sameWeatherCount)
                        //-------------

                        // Reset count
                        sameWeatherCount = 1
                    }

                    // Update previousWeather string and intensity
                    previousWeather = dataPoints[dataPointIndex].icon
                    if precipIntensityRange > 0 {
                        previousPrecipIntensityRange = precipIntensityRange
                    }
                } else {
                    // First cell so there won't be a previous weather
                    sameWeatherCount += 1
                    previousWeather = dataPoints[dataPointIndex].icon
                    if previousWeather == "rain" {
                        if let precipIntensity = dataPoints[dataPointIndex].precipIntensity {
                            previousPrecipIntensityRange = self.getIntensityRange(precipIntensity)
                        }
                    }
                }
            }

            self.x += cellWidth
        }
    }

    func compareWeather(dataPoint: DataPoint, previousRange: Int, previous: String, index: Int, lastCell: Bool) -> (sameWeather: Bool, precipIntensityRange: Int) {

        var precipIntensityRange = -1

        guard let icon = dataPoint.icon else {
            return (sameWeather: false, precipIntensityRange: precipIntensityRange)
        }

        if icon == "rain" {
            if let precipIntensity = dataPoint.precipIntensity {
                precipIntensityRange = self.getIntensityRange(precipIntensity)
            }
        }

        // if this weather is the same as the previous weather
        let sameWeather = (previous == icon)
        let rain = (icon == "rain")
        var notLastCell = (index != (self.noOfCells-1))
        if lastCell == true { notLastCell = (index == (self.noOfCells-1))}
        if (sameWeather && notLastCell && !rain) ||
            (sameWeather && notLastCell && rain && precipIntensityRange > 0 && precipIntensityRange == previousRange) {

            return (sameWeather: true, precipIntensityRange: precipIntensityRange)
        }

        return (sameWeather: false, precipIntensityRange: precipIntensityRange)
    }

    func drawTimeLabel(graphHeight: CGFloat, time: Int, cellWidth: CGFloat) {
        let timeLabelHeight: CGFloat = 14.0
        let timeLabelYCenter: CGFloat = self.center.y + (graphHeight/2) + timeLabelHeight + 2.0

        // Update the label frame and text
        let timeLabel = UILabel(frame: CGRect.zero)
        if self.isWidget == true {
            timeLabel.textColor = UIColor.darkGray
        }
        else {
            timeLabel.textColor = UIColor.white
        }
        timeLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.textAlignment = .center
        timeLabel.frame.size = CGSize(width: 4.0 * cellWidth, height: timeLabelHeight)
        timeLabel.text = UnixTimeManager.calculateTimeFromUnix(seconds: time, timeZoneString: self.timeZoneString)
        timeLabel.center = CGPoint(x: self.x, y: timeLabelYCenter)
        timeLabel.isHidden = false
        self.addSubview(timeLabel)
    }

    func drawTemperatureLabel(graphHeight: CGFloat, temperature: Float, cellWidth: CGFloat) {
        let temperatureLabelHeight: CGFloat = 14.0
        let temperatureLabelYCenter: CGFloat = self.center.y - (graphHeight/2) - temperatureLabelHeight - 2.0

        // Update the label frame and text
        let temperatureLabel = UILabel(frame: CGRect.zero)
        if self.isWidget == true {
            temperatureLabel.textColor = UIColor.darkGray
        }
        else {
            temperatureLabel.textColor = UIColor.white
        }
        temperatureLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
        temperatureLabel.adjustsFontSizeToFitWidth = true
        temperatureLabel.textAlignment = .center
        temperatureLabel.frame.size = CGSize(width: 4.0 * cellWidth, height: temperatureLabelHeight)
        if SettingsManager.isCelsius() {
            let celsiusTemp = UnitManager.celsius(fahrenheit: temperature)
            temperatureLabel.text = "\(Int(celsiusTemp))°"
        }
        else {
            temperatureLabel.text = "\(Int(temperature))°"
        }
        //-------------
        temperatureLabel.center = CGPoint(x: self.x, y: temperatureLabelYCenter)
        temperatureLabel.isHidden = false
        self.addSubview(temperatureLabel)
    }

    func shouldShowTimeLabel(startingIndex: Int, index: Int, today: Bool, todayFirstCell: Bool) -> Bool {

        // Does cell need to show time Label
        // 1st condition is for 'normal' graph. Every 4 cells, starting at cell 2
        // 2nd condition is for 'today' graph. StartingIndex cell and then every 4 cells.
        let normalCondition = (index + 2) % 4 == 0 && today == false && index != 0
        let todayCondition = (index - startingIndex + 4) % 4 == 0 && today == true

        return normalCondition || todayCondition || todayFirstCell
    }

    func handleBackgroundThread() {
        if self.backgroundThreadComplete == false {
            self.activityIndicator?.center = self.center
            self.addSubview(self.activityIndicator!)
            self.activityIndicator?.startAnimating()
        } else {
            self.activityIndicator?.removeFromSuperview()
            self.activityIndicator?.stopAnimating()

            if self.dataPoints == nil {
                let label = UILabel(frame: CGRect.zero)
                label.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.thin)
                if self.isWidget == true {
                    label.textColor = UIColor.darkGray
                } else {
                    label.textColor = UIColor.white
                }
                label.text = "Unable to fetch hourly forecast."
                label.sizeToFit()
                label.center = self.center
                self.addSubview(label)
            }
        }
    }
    
    func drawGraphFill(_ index: Int, dataPoint: DataPoint?, rect: CGRect) {
        
        var colour: UIColor!

        if dataPoint == nil {
            colour = UIColor(white: 1.0, alpha: 0.1)
        } else {
            colour = dataPoint!.getRainColour()
        }

        var path: UIBezierPath?

        if index == 0 {
            path = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.bottomLeft], cornerRadii: CGSize(width: 3.0, height: 3.0))
        } else if index == self.noOfCells-1 {
            path = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.topRight, UIRectCorner.bottomRight], cornerRadii: CGSize(width: 3.0, height: 3.0))
        } else {
            path = UIBezierPath(rect: rect)
        }
        
        colour.setFill()
        path!.fill()
    }
    
    func drawBigVerticalLine(_ x: CGFloat, graphHeight: CGFloat) {
        
        let lineExtendedLength: CGFloat = 4.0
        let y = self.center.y - (graphHeight / 2) - lineExtendedLength

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: x, y: y))
        linePath.addLine(to: CGPoint(x: x, y: y + (lineExtendedLength * 2) + graphHeight))
        var color = UIColor.white
        if self.isWidget == true {
            color = UIColor.darkGray
        }
        color.setStroke()
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
    
    func drawAboveBelowVerticalLines(_ x: CGFloat, graphHeight: CGFloat, showTime: Bool) {

        var lineHeight: CGFloat = 2.0
        if showTime == true {
            lineHeight *= 2
        }
        
        let topY = self.center.y - (graphHeight / 2) - lineHeight
        let bottomY = self.center.y + (graphHeight / 2)
        
        // Draw line
        let linePath = UIBezierPath()
        
        // Top Line
        linePath.move(to: CGPoint(x: x, y: topY))
        linePath.addLine(to: CGPoint(x: x, y: topY + lineHeight))
        
        // Bottom Line
        linePath.move(to: CGPoint(x: x, y: bottomY))
        linePath.addLine(to: CGPoint(x: x, y: bottomY + lineHeight))
        
        var color = UIColor(white: 1.0, alpha: 0.7)
        if self.isWidget == true {
            color = UIColor.lightGray
        }
        color.setStroke()
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
    
    func getIntensityRange(_ precipIntensity: Float) -> Int {
        
        if precipIntensity < 0.017 {
            return 1
        } else if precipIntensity < 0.1 {
            return 2
        } else {
            return 3
        }
    }
    
    func drawGraphLabel(_ dataPoint: DataPoint, dataPointindex: Int, cellWidth: CGFloat, sameWeatherCount: Int) {

        let weatherLabel = UILabel(frame: CGRect.zero)
        if self.isWidget == true {
            weatherLabel.textColor = UIColor.black
        } else {
            weatherLabel.textColor = UIColor.white
        }
        weatherLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        weatherLabel.textAlignment = .center
        weatherLabel.isHidden = false

        var enoughSpace = false
        let spacer: CGFloat = 8.0
        let widthAvailable = ((CGFloat(sameWeatherCount + 1) * cellWidth) - (spacer * 2))

        guard dataPointindex > 0 else {
            return
        }

        guard let icon = dataPoint.icon, let summary = dataPoint.summary else {
            return
        }

        if summary == "Partly Cloudy" || summary == "Mostly Cloudy" {
            if let cloudCover = dataPoint.cloudCover {
                let percentage = cloudCover * 100
                weatherLabel.text = "\(summary) (\(Int(percentage))%)"
                weatherLabel.sizeToFit()

                if weatherLabel.frame.width <= widthAvailable {
                    enoughSpace = true
                } else {
                    weatherLabel.text = "\(summary)"
                }
            } else {
                weatherLabel.text = "\(summary)"
            }
        } else if icon == "rain" {
            if let precipProbability = dataPoint.precipProbability {
                let percentage = precipProbability * 100
                weatherLabel.text = "\(summary) (\(Int(percentage))%)"
                weatherLabel.sizeToFit()

                if weatherLabel.frame.width <= widthAvailable {
                    enoughSpace = true
                } else {
                    weatherLabel.text = "\(summary)"
                }
            } else {
                weatherLabel.text = "\(summary)"
            }
        } else {
            weatherLabel.text = "\(summary)"
        }

        weatherLabel.sizeToFit()

        let weatherLabelCenterX: CGFloat = self.x - ((CGFloat(sameWeatherCount) * cellWidth) / 2)
        let weatherLabelCenterY: CGFloat = self.center.y

        if weatherLabel.frame.width <= widthAvailable || enoughSpace == true {
            weatherLabel.center = CGPoint(x: weatherLabelCenterX, y: weatherLabelCenterY)
            self.addSubview(weatherLabel)
        }
    }
}
