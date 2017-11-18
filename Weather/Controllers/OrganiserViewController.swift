//
//  OrganiserViewController.swift
//  Weather
//
//  Created by James Shaw on 23/06/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import WeatherFrontKit

class OrganiserViewController: UIViewController {

    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var insertButton: UIButton!

    var savedLocations = [NSManagedObject]()

    var tempUnitsButton: UIButton!
    var speedUnitsButton: UIButton!
    var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create dismiss button
        self.dismissButton.titleLabel?.textAlignment = .center
        self.dismissButton.titleLabel?.font = Constants.fontAwesome
        self.dismissButton.setTitle(Constants.fontAwesomeCodes["fa-times"]!, for: UIControlState())
        self.dismissButton.setTitleColor(UIColor.white, for: UIControlState())
        //------------
        
        // Create insert button
        self.insertButton.titleLabel?.textAlignment = .center
        self.insertButton.titleLabel?.font = Constants.fontAwesome
        self.insertButton.setTitle(Constants.fontAwesomeCodes["fa-plus"]!, for: UIControlState())
        self.insertButton.setTitleColor(UIColor.white, for: UIControlState())
        //------------
        
        // Set delegate and data source
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.8)
        //---------
        
        // Create footerView with buttons (switches)
        let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 32.0))
        footerView.isUserInteractionEnabled = true
        footerView.backgroundColor = UIColor.clear
        //-----------
        
        // Create temperature button
        self.tempUnitsButton = UIButton(type: .custom)
        self.tempUnitsButton.frame = CGRect(x: 0.0, y: 12.0, width: 90.0, height: 20.0)
        self.tempUnitsButton.addTarget(self, action: #selector(OrganiserViewController.tempUnitsButtonPressed), for: UIControlEvents.touchUpInside)
        self.tempUnitsButton.titleLabel?.textAlignment = .left
        self.tempUnitsButton.setAttributedTitle(self.setButtonAttributedTitle(true), for: UIControlState())
        footerView.addSubview(self.tempUnitsButton)
        //----------
        
        // Create speed button
        self.speedUnitsButton = UIButton(type: .custom)
        self.speedUnitsButton.frame = CGRect(x: footerView.frame.width - 100.0 - 20.0, y: 12.0, width: 110.0, height: 20.0)
        self.speedUnitsButton.addTarget(self, action: #selector(OrganiserViewController.speedUnitsButtonPressed), for: UIControlEvents.touchUpInside)
        self.speedUnitsButton.titleLabel?.textAlignment = .right
        self.speedUnitsButton.setAttributedTitle(self.setButtonAttributedTitle(false), for: UIControlState())
        footerView.addSubview(self.speedUnitsButton)
        //----------
        
        // Create edit button
        self.editButton = UIButton(type: .custom)
        self.editButton.frame = CGRect(x: (footerView.frame.width / 2) - 24.0, y: 12.0, width: 48.0, height: 20.0)
        self.editButton.addTarget(self, action: #selector(OrganiserViewController.editTableView(_:)), for: UIControlEvents.touchUpInside)
        self.editButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
        self.editButton.setTitle("Edit", for: UIControlState())
        footerView.addSubview(self.editButton)
        //-----------
        
        // Set footer
        self.tableView.tableFooterView = footerView

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        LocationManager.shared.startUpdatingLocation()

        self.fetchLocations()
        self.tableView.reloadData()
    }
    
    func fetchLocations() {
        
        // Make fetch request to get all saved locations
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ForecastLocation")
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
    
        do {
            let results = try managedContext.fetch(fetchRequest)
            self.savedLocations = results as! [NSManagedObject]

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")

            let message = "An error occurred attempting to fetch saved locations."
            self.presentErrorAlert(message)
        }

    }
    
    @objc func editTableView(_ sender: AnyObject) {
        
        if self.tableView.isEditing {
            self.tableView.setEditing(false, animated: true);
            self.editButton.setTitle("Edit", for: UIControlState())
        } else {
            self.tableView.setEditing(true, animated: true);
            self.editButton.setTitle("Done", for: UIControlState())
        }
    }
    @objc func tempUnitsButtonPressed() {

        DispatchQueue.main.async {

            let celsius = SettingsManager.isCelsius()
            SettingsManager.setTemperature(celsius: !celsius)

            self.tempUnitsButton.setAttributedTitle(self.setButtonAttributedTitle(true), for: UIControlState())

            NotificationCenter.default.post(name: Constants.Notifications.unitsChanged, object: self, userInfo: nil)
        }
    }
    
    // Speed Units button pressed
    @objc func speedUnitsButtonPressed() {

        DispatchQueue.main.async {

            let mph = SettingsManager.isMPH()
            SettingsManager.setSpeed(mph: !mph)

            self.speedUnitsButton.setAttributedTitle(self.setButtonAttributedTitle(false), for: UIControlState())

            NotificationCenter.default.post(name: Constants.Notifications.unitsChanged, object: self, userInfo: nil)
        }
    }

    @IBAction func insert(_ sender: AnyObject) {
        let add = self.storyboard!.instantiateViewController(withIdentifier: "addLocationViewController") as! AddLocationViewController
        add.index = self.savedLocations.count + 1
        self.present(add, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Constants.Notifications.backFromOrganiser, object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setButtonAttributedTitle(_ isTemperatureButton: Bool) -> NSMutableAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        if isTemperatureButton == true {
            paragraphStyle.alignment = .left
        } else {
            paragraphStyle.alignment = .right
        }
        
        let selectedAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        let notSelectedAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin), NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.5), NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        let attributedString: NSMutableAttributedString!
        
        // if it's the temperature button
        if isTemperatureButton == true {
            if SettingsManager.isCelsius() == true {
                attributedString = NSMutableAttributedString(string: "°C", attributes: selectedAttributes)
                attributedString.append(NSMutableAttributedString(string: " / °F",attributes: notSelectedAttributes))
            } else {
                attributedString = NSMutableAttributedString(string: "°C / ", attributes: notSelectedAttributes)
                attributedString.append(NSMutableAttributedString(string: "°F",attributes: selectedAttributes))
            }
        } else {
            if SettingsManager.isMPH() == true {
                attributedString = NSMutableAttributedString(string: "mph", attributes: selectedAttributes)
                attributedString.append(NSMutableAttributedString(string: " / kph",attributes: notSelectedAttributes))
            } else {
                attributedString = NSMutableAttributedString(string: "mph / ", attributes: notSelectedAttributes)
                attributedString.append(NSMutableAttributedString(string: "kph",attributes: selectedAttributes))
            }
        }
        
        return attributedString
    }
    
    func presentErrorAlert(_ message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "An Error occurred.", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action:UIAlertAction!) in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }

    func constructLocationNames(placemark: CLPlacemark) -> (fullName: String, subName: String) {

        var fullName = "Location not found."
        var subName = "Location not found."

        // Construct location string
        if let city = placemark.locality {
            if let country = placemark.country {
                if let street = placemark.thoroughfare {
                    if let streetNumber = placemark.subThoroughfare {
                        fullName = "\(streetNumber) \(street)"
                        subName = "\(city), \(country)"
                    } else {
                        fullName = "\(street)"
                        subName = "\(city), \(country)"
                    }
                } else {
                    fullName = "\(city)"
                    subName = "\(country)"
                }
            }
        }

        return (fullName, subName)
    }
}

extension OrganiserViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + self.savedLocations.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "organiserTableViewCell") as? OrganiserTableViewCell
        if cell == nil {
            cell = OrganiserTableViewCell.init(style: .default, reuseIdentifier: "organiserTableViewCell")
        }

        // if current location cell
        if indexPath.row == 0 {

            cell!.nameTrailingConstraint.constant = 49.0
            cell!.subNameTrailingContraint.constant = 49.0

            // Create activity indicator
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
            spinner.center = CGPoint(x: self.view.frame.width - (21.0 / 2) - 20.0, y: 40.0)
            cell!.addSubview(spinner)
            spinner.startAnimating()
            //-----------

            // Create location icon label
            let locationIconLabel = UILabel(frame: spinner.frame)
            locationIconLabel.font = Constants.fontAwesome
            locationIconLabel.textColor = UIColor.white
            locationIconLabel.text = Constants.fontAwesomeCodes["fa-location-arrow"]
            //----------

            guard let latitude = LocationManager.shared.latitude, let longitude = LocationManager.shared.longitude else {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                cell!.nameLabel.text = "Current location not found."

                return cell!
            }

            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

                guard let placemarks = placemarks, placemarks.count > 0, error == nil else {
                    DispatchQueue.main.async {
                        spinner.stopAnimating()
                        spinner.removeFromSuperview()

                        cell!.addSubview(locationIconLabel)
                        cell!.nameLabel.text = "Error."
                        cell!.subNameLabel.text = "Unable to fetch current location."
                    }

                    return
                }

                let placemark = placemarks.first!
                let names = self.constructLocationNames(placemark: placemark)
                let fullName = names.fullName
                let subName = names.subName

                DispatchQueue.main.async {
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()

                    cell!.addSubview(locationIconLabel)
                    cell!.nameLabel.text = fullName
                    cell!.subNameLabel.text = subName
                }
            })
        } else {
            cell!.nameTrailingConstraint.constant = 8.0
            cell!.subNameTrailingContraint.constant = 8.0

            // Get name saved in core data
            if let locationName = self.savedLocations[indexPath.row - 1].value(forKey: "name") as? String {
                DispatchQueue.main.async {
                    cell!.nameLabel.text = locationName
                }

                if let locationSubName = self.savedLocations[indexPath.row - 1].value(forKey: "subName") as? String {
                    DispatchQueue.main.async {
                        cell!.subNameLabel.text = locationSubName
                    }
                }
            }
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var dataDict = Dictionary<String, AnyObject>()
        dataDict["pageIndex"] = (indexPath as NSIndexPath).row as AnyObject?

        // Post notification
        NotificationCenter.default.post(name: Constants.Notifications.goToPageViewIndex, object: self, userInfo: dataDict)

        // Dismiss view
        self.dismiss(animated: true, completion: nil)

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.delete(self.savedLocations[(indexPath as NSIndexPath).row - 1] as NSManagedObject)

            // Update the indexes of the locations of the objects after this indexPath
            for index in ((indexPath as NSIndexPath).row - 1)...(self.savedLocations.count - 1) {
                let location = self.savedLocations[index]
                if let previousIndex = location.value(forKey: "index") as? NSNumber {
                    let newIndex = Int(truncating: previousIndex) - 1
                    location.setValue(newIndex, forKey: "index")
                }
            }

            do {
                try managedContext.save()

                SettingsManager.setPageIndex(index: (indexPath as NSIndexPath).row - 1)

                self.savedLocations.remove(at: (indexPath as NSIndexPath).row - 1)
                tableView.deleteRows(at: [indexPath], with: .fade)

            } catch let error as NSError  {
                let message = "An error occurred attempting to delete location."
                self.presentErrorAlert(message)

                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        // Update index of cell that was moved in core data
        let movedLocation = self.savedLocations[(sourceIndexPath as NSIndexPath).row - 1]
        let newIndex = (destinationIndexPath as NSIndexPath).row
        movedLocation.setValue(newIndex, forKey: "index")

        // if row has been moved down
        if (destinationIndexPath as NSIndexPath).row > (sourceIndexPath as NSIndexPath).row {

            // Get all other indexPaths that have moved
            for index in (sourceIndexPath as NSIndexPath).row + 1...(destinationIndexPath as NSIndexPath).row {
                let location = self.savedLocations[index - 1]
                if let previousIndex = location.value(forKey: "index") as? NSNumber {
                    let newIndex = Int(truncating: previousIndex) - 1
                    location.setValue(newIndex, forKey: "index")
                }
            }
        } else if (destinationIndexPath as NSIndexPath).row < (sourceIndexPath as NSIndexPath).row {

            // Get all other indexPaths that have moved
            for index in (destinationIndexPath as NSIndexPath).row...(sourceIndexPath as NSIndexPath).row - 1 {
                let location = self.savedLocations[index - 1]
                if let previousIndex = location.value(forKey: "index") as? NSNumber {
                    let newIndex = Int(truncating: previousIndex) + 1
                    location.setValue(newIndex, forKey: "index")
                }
            }
        }

        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            try managedContext.save()

            self.savedLocations.remove(at: (sourceIndexPath as NSIndexPath).row - 1)
            self.savedLocations.insert(movedLocation, at: (destinationIndexPath as NSIndexPath).row - 1)

        } catch let error as NSError  {
            let message = "An error occurred attempting to delete location."
            self.presentErrorAlert(message)

            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
