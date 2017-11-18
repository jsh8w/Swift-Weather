//
//  AddLocationViewController.swift
//  Weather
//
//  Created by James Shaw on 24/06/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import GoogleMaps
import WeatherFrontKit

class AddLocationViewController: UIViewController {
    
    // IndexPath.row of the OrganiserTableView that this location will be added
    var index: Int?

    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navigationBar: UINavigationBar!

    let searchController = UISearchController(searchResultsController: nil)
    var nameSearchResults:[String] = []
    var subNameSearchResults:[String] = []
    var fullNameSearchResults:[String] = []

    var footerImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorColor = UIColor(white: 1.0, alpha: 0.8)
        
        // Create footerView with 'Powered by Google' logo
        let footerView = UIView()
        self.footerImageView = UIImageView(image: UIImage(named: "powered_by_google"))
        self.footerImageView.frame = CGRect(x: 0.0, y: 10.0, width: self.view.frame.width, height: 20.0)
        self.footerImageView.backgroundColor = UIColor.clear
        self.footerImageView.contentMode = .center
        self.footerImageView.isHidden = true
        footerView.addSubview(self.footerImageView)
        self.tableView.tableFooterView = footerView
        //----------
        
        // Create searchController
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
        self.searchController.searchBar.showsCancelButton = true
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "Search for a Location"
        //-------------
        
        // Add searchBar to navBar
        self.navigationBar.delegate = self
        self.navigationBar.topItem?.titleView = self.searchController.searchBar
        //----------
        
        // Enable Cancel Button
        for view1 in self.searchController.searchBar.subviews {
            for view2 in view1.subviews {
                if view2.isKind(of: UIButton.self) {
                    let button = view2 as! UIButton
                    button.isEnabled = true
                    button.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchController.isActive = true
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    func insertLocation(_ name: String, subName: String, fullName: String) -> Bool {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "ForecastLocation", in:managedContext)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ForecastLocation")
        let predicate = NSPredicate(format: "(fullName == %@)", fullName)
        request.predicate = predicate
        
        do {
            // Execute count request
            let count = try managedContext.count(for: request)
            if count == 0 {
                let location = NSManagedObject(entity: entity!, insertInto: managedContext)
                location.setValue(name, forKey: "name")
                location.setValue(subName, forKey: "subName")
                location.setValue(fullName, forKey: "fullName")
                location.setValue(self.index, forKey: "index")

                try managedContext.save()
                
                return true
                
            } else {
                // Object with this name already exists
                
                // Present error alert
                let message = "'\(fullName)' has already been added to Weather Front. Unable to duplicate location."
                self.presentErrorAlert(message)
                
                return false
            }
            
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            
            // Present error alert
            let message = "An error occured whilst adding the location '\(name)'."
            self.presentErrorAlert(message)
            
            return false
        }
    }
    
    func presentErrorAlert(_ message: String) {
        
        DispatchQueue.main.async {
            self.searchController.isActive = false
            
            let alertController = UIAlertController(title: "An Error occurred.", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action:UIAlertAction!) in }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }
}

extension AddLocationViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }

    // Called whenever search text changes
    func updateSearchResults(for searchController: UISearchController) {

        if searchController.searchBar.text != "" {

            let placesClient = GMSPlacesClient()
            placesClient.autocompleteQuery(searchController.searchBar.text!, bounds: nil, filter: nil) { (results, error) -> Void in

                self.nameSearchResults.removeAll()
                self.subNameSearchResults.removeAll()
                self.fullNameSearchResults.removeAll()

                guard error == nil, let results = results else {
                    self.nameSearchResults.append("Error fetching locations.")
                    self.subNameSearchResults.append("Please check your internet connection.")

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }

                    return
                }

                for result in results {

                    self.nameSearchResults.append(result.attributedPrimaryText.string)
                    self.fullNameSearchResults.append(result.attributedFullText.string)

                    if let secondaryString = result.attributedSecondaryText?.string {
                        self.subNameSearchResults.append(secondaryString)
                    } else {
                        self.subNameSearchResults.append("")
                    }
                }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.footerImageView.isHidden = false
                }
            }
        } else {

            self.nameSearchResults.removeAll()
            self.subNameSearchResults.removeAll()
            self.fullNameSearchResults.removeAll()

            self.tableView.reloadData()

            self.footerImageView.isHidden = true
        }
    }
}

extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameSearchResults.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "searchTableViewCell")
        }

        cell!.backgroundColor = UIColor.clear

        cell!.textLabel?.text = self.nameSearchResults[(indexPath as NSIndexPath).row]
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight.thin)
        cell!.textLabel?.textColor = UIColor.white

        cell!.detailTextLabel?.text = self.subNameSearchResults[(indexPath as NSIndexPath).row]
        cell!.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
        cell!.detailTextLabel?.textColor = UIColor.white

        if self.nameSearchResults[(indexPath as NSIndexPath).row] == "Error fetching locations." {
            cell!.isUserInteractionEnabled = false
        } else {
            cell!.isUserInteractionEnabled = true
        }

        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let name = self.nameSearchResults[(indexPath as NSIndexPath).row]
        let subName = self.subNameSearchResults[(indexPath as NSIndexPath).row]
        let fullName = self.fullNameSearchResults[(indexPath as NSIndexPath).row]

        if self.insertLocation(name, subName: subName, fullName: fullName) == true {
            self.searchController.isActive = false

            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension AddLocationViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
