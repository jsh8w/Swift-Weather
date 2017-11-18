//
//  TodayViewController.swift
//  Weather Front Widget
//
//  Created by James Shaw on 03/08/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import NotificationCenter
import WeatherFrontKit

class TodayViewController: UIViewController, NCWidgetProviding {

    var rainGraphView: RainGraphView!
    var rainfallContainerView: UIView!

    var todayView: TodayView!
    var todayBottomLineView: UIView!

    var latitude: Float?
    var longitude: Float?
    var locationName: String?
    var displayName: String?
    
    // Header View
    var headerView: UIView!
    var locationLabel: UILabel!
    var temperatureLabel: UILabel!
    var summaryLabel: UILabel!
    var bottomLineView: UIView!

    var errorLabel: UILabel!
    var retryButton: UIButton!
    var loadingLabel: UILabel!

    @IBOutlet weak var forecastLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!

    let xBorder: CGFloat = 20.0

    var forecastReady = false
    var locationReady = false
    var precipBool = false
    var rainfallGraphShowing = false
    var firstDraw = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadForecastComplete(notification:)), name: Constants.Notifications.downloadForecastComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadForecastFailed(notification:)), name: Constants.Notifications.downloadForecastFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationFound(notification:)), name: Constants.Notifications.locationFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.locationFailed(notification:)), name: Constants.Notifications.locationFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.coordinatesToAddressComplete(notification:)), name: Constants.Notifications.coordinatesToAddressComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.coordinatesToAddressFailed(notification:)), name: Constants.Notifications.coordinatesToAddressFailed, object: nil)

        LocationManager.shared.initLocationManager()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.refresh()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        // Draw the view first time this method is called
        if self.firstDraw == true {
            self.drawView(maxSize: maxSize)
            
            self.firstDraw = false
        }
        
        DispatchQueue.main.async {
            
            self.todayView.frame.size.width = self.view.frame.width
            
            if activeDisplayMode == NCWidgetDisplayMode.compact {
                self.preferredContentSize = maxSize

                UIView.animate(withDuration: 0.5, animations: {
                    self.todayView.frame.size.height = 45.0
                    self.todayBottomLineView.frame.origin.y = self.todayView.frame.origin.y + 45.0

                    self.todayView.summaryHourlyView.alpha = 1.0
                    self.todayView.todayForecastView.alpha = 0.0

                    self.forecastLabel.alpha = 0.0
                    self.todayBottomLineView.alpha = 0.0
                    self.refreshButton.alpha = 0.0
                })
                
                SettingsManager.setWidgetExpanded(expanded: false)
            } else {
                if self.precipBool == true {
                    self.preferredContentSize = CGSize(width: maxSize.width, height: 395)
                } else {
                    self.preferredContentSize = CGSize(width: maxSize.width, height: 225)
                }
                
                self.todayView.frame.size.height = 120.0
                self.todayBottomLineView.frame.origin.y = self.todayView.frame.origin.y + 120.0

                UIView.animate(withDuration: 0.5, animations: {
                    self.todayView.summaryHourlyView.alpha = 0.0
                    self.todayView.todayForecastView.alpha = 1.0

                    self.forecastLabel.alpha = 1.0
                    if self.errorLabel.alpha == 0.0 && self.loadingLabel.alpha == 0.0 {
                        self.todayBottomLineView.alpha = 1.0
                    }
                    self.refreshButton.alpha = 1.0
                })
                
                SettingsManager.setWidgetExpanded(expanded: true)
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.loadingLabel.center = CGPoint(x: maxSize.width / 2, y: self.preferredContentSize.height / 2)
                self.errorLabel.center = CGPoint(x: maxSize.width / 2, y: (self.preferredContentSize.height / 2) - 20.0)
                let buttonWidth: CGFloat = 100.0
                self.retryButton.frame = CGRect(x: (maxSize.width / 2) - (buttonWidth / 2), y: self.errorLabel.frame.origin.y + self.errorLabel.frame.height + 20.0, width: buttonWidth, height: 30.0)
            })
        }
    }
    
    func readyToDisplay() {
        if self.forecastReady == true && self.locationReady == true {

            let fontSize = self.getLocationLabelFontSize()
            let font = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.thin)
            let fontAwesome = UIFont(name: "FontAwesome", size: fontSize-1.0)!
            let nameAttributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: UIColor.darkGray]
            let iconAttributes = [NSAttributedStringKey.font: fontAwesome, NSAttributedStringKey.foregroundColor: UIColor.darkGray]
            let attributedString = NSMutableAttributedString(string: "\(self.displayName!)   ", attributes: nameAttributes)
            attributedString.append(NSMutableAttributedString(string: Constants.fontAwesomeCodes["fa-location-arrow"]!, attributes: iconAttributes))

            DispatchQueue.main.async {
                self.hideLoadingView()
                self.hideErrorView()
                self.locationLabel.attributedText = attributedString
                self.showView()
            }
        }
    }

    @objc func coordinatesToAddressComplete(notification: Notification) {
        guard let dict = notification.userInfo as? [String: String],
            let fullName = dict["fullName"],
            let displayName = dict["displayName"] else {
            self.forecastDownloadFailed()
            return
        }

        self.locationName = fullName
        self.displayName = displayName
        self.locationReady = true

        self.readyToDisplay()
    }

    @objc func coordinatesToAddressFailed(notification: Notification) {
        self.forecastDownloadFailed()
    }

    @objc func locationFound(notification: Notification) {
        if let managerLatitude = LocationManager.shared.latitude,
            let managerLongitude = LocationManager.shared.longitude {
            self.latitude = managerLatitude
            self.longitude = managerLongitude

            LocationManager.shared.coordinatesToLocation(self.latitude!, longitude: self.longitude!)
        }

        if let latitude = self.latitude, let longitude = self.longitude {
            self.getForecast(latitude: latitude, longitude: longitude)
        } else {
            self.forecastDownloadFailed()
        }
    }

    @objc func locationFailed(notification: Notification) {
        self.forecastDownloadFailed()
    }
    
    func getForecast(latitude: Float, longitude: Float) {
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            DownloadManager.shared.downloadWidgetData(latitude: latitude, longitude: longitude, forecast: Forecast())
        })
    }

    @objc func downloadForecastComplete(notification: Notification) {

        guard let dict = notification.userInfo as? [String: Forecast], let forecast = dict["forecast"] else {
            self.forecastDownloadFailed()
            return
        }

        self.forecastDownloadComplete(forecast: forecast)
    }

    func forecastDownloadComplete(forecast: Forecast) {
        
        let celsius = SettingsManager.isCelsius()

        if let summary = forecast.currently?.summary {
            DispatchQueue.main.async {
                self.summaryLabel.text = summary
            }
        } else {
            DispatchQueue.main.async {
                self.summaryLabel.text = "Summary not available."
            }
        }

        if let temperature = forecast.currently?.temperature {
            if celsius == true {
                let celsiusTemp = UnitManager.celsius(fahrenheit: temperature)
                DispatchQueue.main.async {
                    self.temperatureLabel.text = "\(Int(celsiusTemp))°"
                }
            } else {
                DispatchQueue.main.async {
                    self.temperatureLabel.text = "\(Int(temperature))°"
                }
            }
        } else {
            DispatchQueue.main.async {
                self.temperatureLabel.text = "n/a"
            }
        }

        if let hourlyDataPoints = forecast.hourly?.hourlyDataPoints {
            self.todayView.summaryHourlyView.dataPoints = hourlyDataPoints[0]
            self.todayView.todayForecastView.dataPoints = hourlyDataPoints[0]
            
            // Find max and min temperatures
            var maxTemperature: Float = -1000.0
            var minTemperature: Float = 1000.0
            for dataPoint in hourlyDataPoints[0] {
                if let temperature = dataPoint.temperature {
                    if temperature > maxTemperature {
                        maxTemperature = temperature
                    }
                    
                    if temperature < minTemperature {
                        minTemperature = temperature
                    }
                }
            }
        }

        if let minutelyDataPoints = forecast.minutely?.dataPoints {
            var precipPoints:[Float] = []
            self.precipBool = false

            for dataPoint in minutelyDataPoints {
                if let precip = dataPoint.precipIntensity {
                    precipPoints.append(precip)
                    if precip != 0.0 {
                        self.precipBool = true
                    }
                }
            }

            self.rainGraphView.graphPoints = precipPoints
            self.rainGraphView.minutelyAvailable = true

            DispatchQueue.main.async {
                if self.precipBool == false {
                    self.rainfallContainerView.alpha = 0.0
                    self.rainfallGraphShowing = false
                } else {
                    self.rainfallContainerView.alpha = 1.0
                    self.rainfallGraphShowing = true
                }
            }
        } else {
            self.rainfallContainerView.alpha = 0.0
            self.rainfallGraphShowing = false
            self.rainGraphView.minutelyAvailable = false
            self.rainGraphView.graphPoints = []

            DispatchQueue.main.async {
                self.rainGraphView.noPrecipLabel.text = "Precipitation data not available."
                self.rainGraphView.noPrecipLabel.isHidden = false
            }
        }

        self.forecastReady = true
        self.readyToDisplay()
    }

    @objc func downloadForecastFailed(notification: Notification) {
        self.forecastDownloadFailed()
    }

    func forecastDownloadFailed() {
        self.forecastReady = false
        self.locationReady = false
        
        DispatchQueue.main.async {
            self.hideLoadingView()
            self.hideView()
            self.presentErrorView()
        }
    }

    func refresh() {
        self.forecastReady = false
        self.locationReady = false
        
        DispatchQueue.main.async {
            self.retryButton.alpha = 0.0
            self.retryButton.isEnabled = false
            self.errorLabel.alpha = 0.0

            self.hideView()
            self.presentLoadingView()
        }

        LocationManager.shared.startUpdatingLocation()
    }
    
    @objc func retryButtonPressed(_ sender: AnyObject) {
        self.refresh()
    }
    
    @IBAction func refreshButtonPressed(_ sender: AnyObject) {
        self.refresh()
    }
    
    @objc func openAppButtonPressed(_ sender: AnyObject) {
        let appURL = URL(string: "WeatherFront://")
        self.extensionContext?.open(appURL!, completionHandler:nil)
    }
    
    // MARK: Drawing Code
    
    func drawView(maxSize: CGSize) {

        let gesture = UITapGestureRecognizer(target: self, action: #selector(TodayViewController.openAppButtonPressed(_:)))
        self.view.addGestureRecognizer(gesture)

        self.refreshButton.setTitle(Constants.fontAwesomeCodes["fa-refresh"], for: UIControlState())
        self.refreshButton.titleLabel?.textAlignment = .right

        self.drawHeaderView()

        let todayViewHeight: CGFloat = 45.0
        let todayViewY: CGFloat = self.headerView.frame.origin.y + self.headerView.frame.height
        self.todayView = TodayView(frame: CGRect(x: 0.0, y: todayViewY, width: maxSize.width, height: todayViewHeight))
        self.todayView.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.view.addSubview(self.todayView)
        }

        self.todayBottomLineView = UIView(frame: CGRect(x: 0.0, y: self.todayView.frame.origin.y + self.todayView.frame.height, width: maxSize.width, height: 0.5))
        self.todayBottomLineView.backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        self.todayBottomLineView.alpha = 0.0
        DispatchQueue.main.async {
            self.view.addSubview(self.todayBottomLineView)
        }

        self.drawRainfallGraph()
        self.setForecastLabelText()
        self.drawErrorView()
        self.drawLoadingView()
        self.setLabelFontSizes()
        self.hideView()
    }
    
    func drawHeaderView() {
        
        // Draw headerView
        let headerHeight: CGFloat = 70.0
        let yBorder: CGFloat = 12.0
        let temperatureLabelWidth: CGFloat = 100.0
        self.headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: headerHeight))
        DispatchQueue.main.async(execute: { () -> Void in
            self.view.addSubview(self.headerView)
        })
        //-----------
        
        // Draw bottomLineView
        self.bottomLineView = UIView(frame: CGRect(x: 0.0, y: headerHeight - 0.5, width: self.headerView.frame.width, height: 0.5))
        self.bottomLineView.backgroundColor = UIColor.darkGray
        DispatchQueue.main.async(execute: { () -> Void in
            self.headerView.addSubview(self.bottomLineView)
        })
        //------------
        
        // Add temperatureLabel
        self.temperatureLabel = UILabel(frame: CGRect(x: self.headerView.frame.width - self.xBorder - temperatureLabelWidth, y: 0.0, width: temperatureLabelWidth, height: self.headerView.frame.height))
        self.temperatureLabel.textColor = UIColor.black
        self.temperatureLabel.adjustsFontSizeToFitWidth = true
        self.temperatureLabel.textAlignment = .right
        DispatchQueue.main.async(execute: { () -> Void in
            self.headerView.addSubview(self.temperatureLabel)
        })
        //-----------
        
        // Draw LocationLabel
        self.locationLabel = UILabel(frame: CGRect(x: self.xBorder, y: yBorder, width: self.temperatureLabel.frame.origin.x - self.xBorder, height: 18.0))
        self.locationLabel.textColor = UIColor.darkGray
        self.locationLabel.adjustsFontSizeToFitWidth = true
        self.locationLabel.textAlignment = .left
        self.locationLabel.backgroundColor = UIColor.clear
        DispatchQueue.main.async(execute: { () -> Void in
            self.headerView.addSubview(self.locationLabel)
        })
        //--------------
        
        // Draw summaryLabel
        self.summaryLabel = UILabel(frame: CGRect(x: self.xBorder, y: self.locationLabel.frame.origin.y + self.locationLabel.frame.height + 3.0, width: self.locationLabel.frame.width, height: self.headerView.frame.height - self.locationLabel.frame.origin.y - self.locationLabel.frame.height - yBorder))
        self.summaryLabel.textColor = UIColor.black
        self.summaryLabel.adjustsFontSizeToFitWidth = true
        self.summaryLabel.textAlignment = .left
        self.summaryLabel.backgroundColor = UIColor.clear
        DispatchQueue.main.async {
            self.headerView.addSubview(self.summaryLabel)
        }
    }
    
    func drawRainfallGraph() {
        let rainfallContainerHeight: CGFloat = 170.0
        let todayViewExpandedHeight: CGFloat = 120.0
        let rainfallContainerY: CGFloat = self.todayView.frame.origin.y + todayViewExpandedHeight
        self.rainfallContainerView = UIView(frame: CGRect(x: 0.0, y: rainfallContainerY, width: self.view.frame.width, height: rainfallContainerHeight))
        self.rainfallContainerView.alpha = 0.0
        DispatchQueue.main.async {
            self.view.addSubview(self.rainfallContainerView)
        }

        self.rainGraphView = RainGraphView(frame: CGRect(x: 0.0, y: 0.0, width: self.rainfallContainerView.frame.width, height: self.rainfallContainerView.frame.height))
        self.rainGraphView.isWidget = true
        DispatchQueue.main.async {
            self.rainfallContainerView.addSubview(self.rainGraphView)
        }
    }
    
    func setForecastLabelText() {
        let poweredAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        let forecastAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        let attributedString = NSMutableAttributedString(string: "Powered by ", attributes: poweredAttributes)
        attributedString.append(NSMutableAttributedString(string: "Dark Sky",attributes: forecastAttributes))
        self.forecastLabel.attributedText = attributedString
    }

    func hideView() {
        self.headerView.alpha = 0.0
        self.rainfallContainerView.alpha = 0.0
        self.todayView.alpha = 0.0
        self.forecastLabel.alpha = 0.0
        self.todayBottomLineView.alpha = 0.0
        self.refreshButton.alpha = 0.0
    }
    
    func showView() {
        self.headerView.alpha = 1.0
        self.todayView.alpha = 1.0
        
        if SettingsManager.widgetExpanded() == true {
            self.forecastLabel.alpha = 1.0
            self.todayBottomLineView.alpha = 1.0
            self.refreshButton.alpha = 1.0

        } else {
            self.forecastLabel.alpha = 0.0
            self.todayBottomLineView.alpha = 0.0
            self.refreshButton.alpha = 0.0
        }
        
        if self.rainfallGraphShowing == true {
            self.rainfallContainerView.alpha = 1.0
        } else {
            self.rainfallContainerView.alpha = 0.0
        }
    }

    func drawErrorView() {
        self.errorLabel = UILabel(frame: CGRect.zero)
        self.errorLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        self.errorLabel.text = "Error fetching Forecast."
        self.errorLabel.textAlignment = .center
        self.errorLabel.sizeToFit()
        self.errorLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 20.0)
        self.errorLabel.alpha = 0.0
        self.view.addSubview(self.errorLabel)

        self.retryButton = UIButton(type: UIButtonType.custom)
        self.retryButton.setTitle("Retry", for: UIControlState())
        self.retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
        self.retryButton.setTitleColor(UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5), for: UIControlState())
        self.retryButton.alpha = 0.0
        self.retryButton.isEnabled = false
        self.retryButton.addTarget(self, action: #selector(TodayViewController.retryButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        self.retryButton.backgroundColor = UIColor.clear
        self.retryButton.layer.cornerRadius = 5
        self.retryButton.layer.borderWidth = 1
        self.retryButton.layer.borderColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5).cgColor
        let buttonWidth: CGFloat = 100.0
        self.retryButton.frame = CGRect(x: (self.view.frame.width / 2) - (buttonWidth / 2), y: self.errorLabel.frame.origin.y + self.errorLabel.frame.height + 20.0, width: buttonWidth, height: 30.0)
        self.view.addSubview(self.retryButton)
    }
    
    func presentErrorView() {
        self.errorLabel.sizeToFit()
        self.errorLabel.center = self.view.center
        let buttonWidth: CGFloat = 100.0
        self.retryButton.frame = CGRect(x: (self.view.frame.width / 2) - (buttonWidth / 2), y: self.errorLabel.frame.origin.y + self.errorLabel.frame.height + 20.0, width: buttonWidth, height: 30.0)

        self.hideView()

        UIView.animate(withDuration: 0.5, animations: {
            self.retryButton.alpha = 1.0
            self.errorLabel.alpha = 1.0
        })
        
        self.retryButton.isEnabled = true
        self.view.bringSubview(toFront: self.retryButton)
        self.view.clipsToBounds = true
    }
    
    func hideErrorView() {
        self.retryButton.alpha = 0.0
        self.errorLabel.alpha = 0.0

        UIView.animate(withDuration: 0.5, animations: {
            self.showView()
        })
    }
    
    func drawLoadingView() {
        self.loadingLabel = UILabel(frame: CGRect.zero)
        self.loadingLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
        self.loadingLabel.text = "Fetching forecast data."
        self.loadingLabel.textAlignment = .center
        self.loadingLabel.sizeToFit()
        self.loadingLabel.center = self.view.center
        self.loadingLabel.alpha = 0.0
        self.view.addSubview(self.loadingLabel)
    }
    
    func presentLoadingView() {
        self.loadingLabel.sizeToFit()
        self.loadingLabel.center = self.view.center
        self.loadingLabel.alpha = 1.0
    }
    
    func hideLoadingView() {
        self.loadingLabel.alpha = 0.0
    }
    
    // Remove big left margin
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func setLabelFontSizes() {
        
        // Get screen size
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
            // iPhone 4s
            self.locationLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 58.0, weight: UIFont.Weight.ultraLight)
            self.loadingLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
            self.errorLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
        case 568.0:
            // iPhone 5s
            self.locationLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 58.0, weight: UIFont.Weight.ultraLight)
            self.loadingLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
            self.errorLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
        case 667.0:
            // iPhone 6s
            self.locationLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 58.0, weight: UIFont.Weight.ultraLight)
            self.loadingLabel.font = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight.thin)
            self.errorLabel.font = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight.thin)
        case 736.0:
            // iPhone 6s+
            self.locationLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 58.0, weight: UIFont.Weight.ultraLight)
            self.loadingLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.thin)
            self.errorLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.thin)
        default:
            print("not an iPhone")
            
            self.locationLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 26.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 60.0, weight: UIFont.Weight.ultraLight)
            self.loadingLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.thin)
            self.errorLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.thin)
        }
    }
    
    func getLocationLabelFontSize() -> CGFloat {
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
            // iPhone 4s
            return 12.0
        case 568.0:
            // iPhone 5s
            return 14.0
        case 667.0:
            // iPhone 6s
            return 14.0
        case 736.0:
            // iPhone 6s+
            return 16.0
        default:
            return 16.0
        }
    }
}
