//
//  LocationViewController.swift
//  Weather
//
//  Created by James Shaw on 19/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import MapKit
import WeatherFrontKit

class LocationViewController: UIViewController, UIScrollViewDelegate {

    var forecast = Forecast()
    
    // Latitude and longitude and locationName
    var latitude: Float?
    var longitude: Float?
    var locationName: String?
    var displayName: String?
    var isCurrentLocation: Bool?
    //--------------

    var scrollView: UIScrollView!
    var headerView: UIView!
    var maskView: UIView!
    var contentView: UIView!
    var touchesView: UIView!
    var darkView: UIView!
    var rainGraphView: RainGraphView!
    
    // Loading View
    var loadingView: UIView!
    var loadingLabel: UILabel!
    var loadingNameLabel: UILabel!
    var visualEffectView: UIVisualEffectView!
    var retryButton: UIButton!
    //--------------
    
    // Elements in headerView
    var locationLabel: UILabel!
    var temperatureLabel: UILabel!
    var summaryLabel: UILabel!
    var iconLabel: UILabel!
    var summaryView: UIView!
    var forecastDetailsView: ForecastDetailsView!
    var bottomLineView: UIView!
    var detailSummaryPrompt: UILabel!
    //---------------

    var dailyViewController: DailyViewController!
    
    // Constants
    let topBorder: CGFloat = 20.0
    let bottomBorder: CGFloat = 37.0
    var maskStartingY: CGFloat = 0.0 // Distance between top of scrolling content and top of screen
    var maskMaxTravellingDistance: CGFloat = 0.0 // Distance the mask can move upwards before its content starts scrolling and gets clipped
    //------------
    
    // Indicates whether summary or detail is showing at the top of the view.
    var summaryShowing = true

    var forecastButton: UIButton!
    
    // Indicates this is the first viewWillAppear of the instance of view controller
    // We need to make API call if this is true
    var firstViewWillAppear = true
    var firstLocationFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.drawView()
        self.drawLoadingView()

        self.observeLocationNotifications()
        self.observeDownloadNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.unitsChanged(_:)), name: Constants.Notifications.unitsChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.firstViewWillAppear == true {

            DispatchQueue.main.async {
                self.presentLoadingView()
            }

            if self.isCurrentLocation == false {
                guard let locationName = self.locationName else {
                    return
                }

                LocationManager.shared.locationToCoordinates(locationName)
            } else {
                LocationManager.shared.startUpdatingLocation()
            }

            self.firstViewWillAppear = false
        }
    }
    
    func getForecast(_ latitude: Float, longitude: Float) {
        DispatchQueue.global(qos: .default).async(execute: { () -> Void in
            DownloadManager.shared.downloadData(latitude: latitude, longitude: longitude, forecast: self.forecast)
        })
    }
    
    // Forecast failed
    func forecastDownloadFailed() {
        DispatchQueue.main.async {
            self.loadingLabel.text = "Error fetching Forecast."
            self.loadingLabel.sizeToFit()
            self.retryButton.isEnabled = true

            UIView.animate(withDuration: 1.0, animations: {
                self.retryButton.alpha = 1.0
            })

            self.presentLoadingView()
        }
    }
    
    // Notification from OrganiserViewController indicating units of temperature/speed have changed
    @objc func unitsChanged(_ notification: Notification) {
        self.updateViewWithForecast()
    }
    
    func calculateWindDirection(_ degrees: Float) -> String {

        // Array of direction strings
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let count = directions.count

        // Calculate which direction
        let i = (Int(degrees) + (180/count))/(360/count)

        return directions[i % count]
    }
    
    @objc func detailSummarySwitch() {
        
        if self.summaryShowing == true {
            UIView.animate(withDuration: 0.5, animations: {
                self.summaryView.alpha = 0.0
                self.forecastDetailsView.alpha = 1.0
                self.detailSummaryPrompt.text = Constants.fontAwesomeCodes["fa-angle-down"]
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.summaryView.alpha = 1.0
                self.forecastDetailsView.alpha = 0.0
                self.detailSummaryPrompt.text = Constants.fontAwesomeCodes["fa-angle-up"]
            })
        }

        self.summaryShowing = !self.summaryShowing
    }
    
    // Refresh button
    func refresh() {

        if self.isCurrentLocation == true {
            LocationManager.shared.startUpdatingLocation()

            if let managerLatitude = LocationManager.shared.latitude, let managerLongitude = LocationManager.shared.longitude {
                self.latitude = managerLatitude
                self.longitude = managerLongitude

                LocationManager.shared.coordinatesToLocation(self.latitude!, longitude: self.longitude!)
            }
        }

        if let latitude = self.latitude, let longitude = self.longitude {
            
            DispatchQueue.main.async {
                self.presentLoadingView()
            }

            self.getForecast(latitude, longitude: longitude)
        } else {
            self.forecastDownloadFailed()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Get offsetY
        let offsetY = scrollView.contentOffset.y
        
        // The frame of the mask when scrolled
        let newMaskHeight: CGFloat!
        let newMaskY: CGFloat!
        let newMaskFrame: CGRect!
        
        // The frame of the content when scrolled
        let newContentY: CGFloat!
        let newContentFrame: CGRect!
        
        // The frame of the header when scrolled
        let newHeaderY: CGFloat!
        let newHeaderFrame: CGRect!
        
        // Calculate the new frame of the maskView, contentView and headerView
        if offsetY <= self.maskMaxTravellingDistance {
            newMaskHeight = self.view.bounds.height - self.maskStartingY - self.bottomBorder + offsetY
            newMaskY = self.maskStartingY
            newMaskFrame = CGRect(x: 0.0, y: newMaskY, width: self.view.frame.width, height: newMaskHeight)
            
            newContentFrame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.contentView.frame.height)
            
            newHeaderY = self.headerView.bounds.origin.y + self.topBorder - offsetY
            
        } else {
            newMaskHeight = self.view.bounds.height - self.maskStartingY - self.bottomBorder + self.maskMaxTravellingDistance
            newMaskY = self.maskStartingY - self.maskMaxTravellingDistance + offsetY
            newMaskFrame = CGRect(x: 0.0, y: newMaskY, width: self.view.frame.width, height: newMaskHeight)
            
            newContentY = self.maskMaxTravellingDistance - offsetY
            newContentFrame = CGRect(x: 0.0, y: newContentY, width: self.view.frame.width, height: self.contentView.frame.height)
            
            newHeaderY = self.headerView.bounds.origin.y + self.topBorder - self.maskMaxTravellingDistance
        }
        
        newHeaderFrame = CGRect(x: self.headerView.bounds.origin.x, y: newHeaderY, width: self.headerView.frame.size.width, height: self.headerView.bounds.size.height)
        
        DispatchQueue.main.async {
            self.maskView.frame = newMaskFrame
            self.contentView.frame = newContentFrame
            self.headerView.frame = newHeaderFrame
        }
        
        // Fade summaryView as we scroll
        if offsetY <= (self.maskMaxTravellingDistance / 2.0) {
            let decimal = 1.0 - (offsetY / (self.maskMaxTravellingDistance / 2.0))
            
            if self.summaryShowing {
                self.summaryView.alpha = decimal
            } else {
                self.forecastDetailsView.alpha = decimal
            }
            
            self.detailSummaryPrompt.alpha = decimal
        } else {
            if self.summaryShowing {
                self.summaryView.alpha = 0.0
            } else {
                self.forecastDetailsView.alpha = 0.0
            }
            
            self.detailSummaryPrompt.alpha = 0.0
        }
        
        // Disable interaction with summary switch if the headerView is compressed in size
        if offsetY > 0.0 {
            self.touchesView.isUserInteractionEnabled = false
        } else {
            self.touchesView.isUserInteractionEnabled = true
        }
    }
    
    func presentLoadingView() {
        self.view.addSubview(self.loadingView)
    }
    
    func hideLoadingView() {
        
        // View Fade animation
        UIView.animate(withDuration: 1.0, animations: {
            self.loadingView.alpha = 0.0
            self.loadingLabel.alpha = 0.0

            self.view.backgroundColor = self.forecast.backgroundColour()
            
        }, completion: { (value: Bool) in
            self.loadingView.removeFromSuperview()
            self.loadingView.alpha = 1.0
            self.loadingLabel.alpha = 1.0
        })
        
        // Disable user interaction
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func retryButtonPressed(_ sender: AnyObject) {
        
        DispatchQueue.main.async {
            self.loadingLabel.text = "Fetching weather data"
            self.loadingLabel.sizeToFit()
            self.retryButton.alpha = 0.0
            self.retryButton.isEnabled = false
        }

        self.refresh()
    }
    
    @objc func openSafariForecast(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: "https://darksky.net/poweredby/")!, options: [:], completionHandler: nil)
    }
    
    func presentErrorAlert(_ message: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            let alertController = UIAlertController(title: "An Error occurred.", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action:UIAlertAction!) in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:nil)
        })
    }
    
    func setLabelFontSizes() {
        
        // Get screen size
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
            // iPhone 4s
            self.locationLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 55.0, weight: UIFont.Weight.ultraLight)
            self.iconLabel.font = UIFont(name: "WeatherIcons-Regular", size: 55.0)
        case 568.0:
            // iPhone 5s
            self.locationLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 65.0, weight: UIFont.Weight.ultraLight)
            self.iconLabel.font = UIFont(name: "WeatherIcons-Regular", size: 60.0)
        case 667.0:
            // iPhone 6s
            self.locationLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 26.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 95.0, weight: UIFont.Weight.ultraLight)
            self.iconLabel.font = UIFont(name: "WeatherIcons-Regular", size: 85.0)
        case 736.0:
            // iPhone 6s+
            self.locationLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 26.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 110.0, weight: UIFont.Weight.ultraLight)
            self.iconLabel.font = UIFont(name: "WeatherIcons-Regular", size: 95.0)
        default:
            print("not an iPhone")
            
            self.locationLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
            self.summaryLabel.font = UIFont.systemFont(ofSize: 26.0, weight: UIFont.Weight.light)
            self.temperatureLabel.font = UIFont.systemFont(ofSize: 110.0, weight: UIFont.Weight.ultraLight)
            self.iconLabel.font = UIFont(name: "WeatherIcons-Regular", size: 95.0)
        }
        
    }
    
    func setRainfallGraphHeight() -> CGFloat {
        
        // Get screen size
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
            // iPhone 4s
            return 180.0
        case 568.0:
            // iPhone 5s
            return 180.0
        case 667.0:
            // iPhone 6s
            return 200.0
        case 736.0:
            // iPhone 6s+
            return 250.0
        default:
            print("not an iPhone")
            return 200.0
        }
    }
}

// MARK: LocationManager Notification Observations
extension LocationViewController {
    func observeLocationNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(locationFound(_:)), name: Constants.Notifications.locationFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationFailed(_:)), name: Constants.Notifications.locationFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addressToCoordinatesComplete(_:)), name: Constants.Notifications.addressToCoordinatesComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addressToCoordinatesFailed(_:)), name: Constants.Notifications.addressToCoordinatesFailed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(coordinatesToAddressComplete(_:)), name: Constants.Notifications.coordinatesToAddressComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(coordinatesToAddressFailed(_:)), name: Constants.Notifications.coordinatesToAddressFailed, object: nil)
    }

    @objc func locationFound(_ notification: Notification) {

        // Check if this is the current location, we've already hit viewWillAppear, and this is the first time getting location
        if self.isCurrentLocation == true && self.firstViewWillAppear == false && self.firstLocationFound == false {
            self.firstLocationFound = true

            guard let managerLatitude = LocationManager.shared.latitude, let managerLongitude = LocationManager.shared.longitude else {
                return
            }

            self.latitude = managerLatitude
            self.longitude = managerLongitude
            LocationManager.shared.coordinatesToLocation(self.latitude!, longitude: self.longitude!)

            self.getForecast(self.latitude!, longitude: self.longitude!)
        }
    }

    @objc func locationFailed(_ notification: Notification) {

        if self.isCurrentLocation == true && self.firstViewWillAppear == false && self.firstLocationFound == false {
            self.forecastDownloadFailed()
        }
    }

    @objc func addressToCoordinatesFailed(_ notification: Notification) {
        if self.isCurrentLocation == false {
            self.forecastDownloadFailed()
        }
    }

    @objc func addressToCoordinatesComplete(_ notification: Notification) {

        guard let dict = (notification as NSNotification).userInfo as? Dictionary<String, AnyObject> else { return }
        guard let latitude = dict["latitude"] as? Float else { return }
        guard let longitude = dict["longitude"] as? Float else { return }
        guard let address = dict["address"] as? String else { return }

        if self.isCurrentLocation == false {
            guard let locationName = self.locationName else {
                return
            }

            self.latitude = latitude
            self.longitude = longitude

            if address == locationName {
                self.getForecast(latitude, longitude: longitude)
            }
        }
    }

    @objc func coordinatesToAddressFailed(_ notification: Notification) {
        if self.isCurrentLocation == true {
            self.forecastDownloadFailed()
        }
    }

    @objc func coordinatesToAddressComplete(_ notification: Notification) {

        guard let dict = (notification as NSNotification).userInfo as? Dictionary<String, String> else { return }
        guard let fullName = dict["fullName"] else { return }
        guard let displayName = dict["displayName"] else { return }

        if self.isCurrentLocation == true {
            self.locationName = fullName
            self.displayName = displayName

            DispatchQueue.main.async(execute: { () -> Void in
                self.locationLabel.text = self.displayName
            })
        }
    }
}

// MARK: Location Manager Observations
extension LocationViewController {

    func observeDownloadNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(downloadForecastComplete(_:)), name: Constants.Notifications.downloadForecastComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadForecastFailed(_:)), name: Constants.Notifications.downloadForecastFailed, object: nil)
    }

    @objc func downloadForecastComplete(_ notification: Notification) {

        guard let dict = (notification as NSNotification).userInfo as? Dictionary<String, Forecast> else { return }
        guard let forecast = dict["forecast"] else { return }

        if forecast == self.forecast {
            self.forecast = forecast

            self.updateViewWithForecast()
        }
    }

    @objc func downloadForecastFailed(_ notification: Notification) {
        self.forecastDownloadFailed()
    }
}

extension LocationViewController: DailyViewControllerDelegate {
    func didSelectRow(expand: Bool) {
        if expand == true {
            self.contentView.frame.size.height += 50.0
            self.scrollView.contentSize.height += 50.0
            self.dailyViewController.view.frame.size.height += 50.0
            self.dailyViewController.tableView.frame.size.height += 50.0
            self.darkView.frame.size.height += 50.0

            UIView.animate(withDuration: 0.3, animations: {
                self.forecastButton.frame.origin.y += 50.0
            })
        } else {
            self.contentView.frame.size.height -= 50.0
            self.scrollView.contentSize.height -= 50.0
            self.dailyViewController.view.frame.size.height -= 50.0
            self.dailyViewController.tableView.frame.size.height -= 50.0
            self.darkView.frame.size.height -= 50.0

            UIView.animate(withDuration: 0.3, animations: {
                self.forecastButton.frame.origin.y -= 50.0
            })
        }
    }
}
