//
//  LocationManager.swift
//  Weather
//
//  Created by James Shaw on 27/06/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

open class LocationManager: NSObject {

    open static let shared = LocationManager()

    let locationManager = CLLocationManager()
    open var latitude: Float?
    open var longitude: Float?

    open func initLocationManager() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    open func requestAuthorisation() {
        self.locationManager.requestWhenInUseAuthorization()
    }

    open func startUpdatingLocation() {
        // Need to check authorisation for using location services has been given
        let authstate = CLLocationManager.authorizationStatus()
        if (authstate != CLAuthorizationStatus.authorizedWhenInUse) {
            self.requestAuthorisation()
        }
        
        self.locationManager.startUpdatingLocation()
    }

    open func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }

    // Convert address to coordinates - for saved location
    open func locationToCoordinates(_ address: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in

            guard let placemarks = placemarks, placemarks.count > 0, error == nil else {
                NotificationCenter.default.post(name: Constants.Notifications.addressToCoordinatesFailed, object: nil)
                return
            }

            let placemark = placemarks.first!
            let latitude = Float(placemark.location!.coordinate.latitude)
            let longitude = Float(placemark.location!.coordinate.longitude)

            var notificationDict:[String: Any] = [:]
            notificationDict["latitude"] = latitude
            notificationDict["longitude"] = longitude
            notificationDict["address"] = address
            NotificationCenter.default.post(name: Constants.Notifications.addressToCoordinatesComplete, object: self, userInfo: notificationDict)
        })
    }
    
    // For current location
    open func coordinatesToLocation(_ latitude: Float, longitude: Float) {

        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

            guard let placemarks = placemarks, placemarks.count > 0, error == nil else {
                NotificationCenter.default.post(name: Constants.Notifications.coordinatesToAddressFailed, object: nil)
                return
            }

            let placemark = placemarks.first!
            let names = self.constructLocationNames(placemark: placemark)
            let fullName = names.fullName
            let displayName = names.displayName

            var notificationDict:[String: String] = [:]
            notificationDict["fullName"] = fullName
            notificationDict["displayName"] = displayName
            NotificationCenter.default.post(name: Constants.Notifications.coordinatesToAddressComplete, object: self, userInfo: notificationDict)
        })
    }

    open func constructLocationNames(placemark: CLPlacemark) -> (fullName: String, displayName: String) {

        var fullName = "Location not found."
        var displayName = "Location not found."

        // Construct location string
        if let city = placemark.locality {
            if let street = placemark.thoroughfare {
                if let streetNumber = placemark.subThoroughfare {
                    fullName = "\(streetNumber) \(street), \(city)"
                    displayName = "\(streetNumber) \(street), \(city)"
                } else {
                    fullName = "\(street), \(city)"
                    displayName = "\(street), \(city)"
                }
            } else {
                fullName = city
                displayName = "\(city)"
            }
        }

        return (fullName, displayName)
    }
}

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        self.requestAuthorisation()

        if locations.count > 0 {
            self.latitude = Float(locations.last!.coordinate.latitude)
            self.longitude = Float(locations.last!.coordinate.longitude)

            NotificationCenter.default.post(name: Constants.Notifications.locationFound, object: nil)
        }

        self.stopUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NotificationCenter.default.post(name: Constants.Notifications.locationFailed, object: nil)
    }
}
