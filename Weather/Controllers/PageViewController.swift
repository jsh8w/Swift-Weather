//
//  ViewController.swift
//  Weather
//
//  Created by James Shaw on 18/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import CoreData
import WeatherFrontKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class PageViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    @IBOutlet weak var pageControl: LocationPageControl!
    var savedLocations = [NSManagedObject]()
    var pages = [LocationViewController]()
    var pageContainer: UIPageViewController!
    var currentIndex: Int?
    fileprivate var pendingIndex: Int?

    var refreshButton: UIButton!
    var organiserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.goToPageViewIndex(_:)), name: Constants.Notifications.goToPageViewIndex, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.backFromOrganiser(_:)), name: Constants.Notifications.backFromOrganiser, object: nil)

        self.currentIndex = SettingsManager.pageIndex()

        self.fetchLocations()
        self.initLocations()

        self.pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageContainer.delegate = self
        self.pageContainer.dataSource = self
        let viewControllers:[UIViewController] = [self.pages[self.currentIndex!]]
        self.pageContainer.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        self.view.addSubview(pageContainer.view)
        self.view.bringSubview(toFront: self.pageControl)
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = self.currentIndex!
        
        // Add line above pageControl
        let bottomLineView = UIView(frame: CGRect(x: 0.0, y: self.view.frame.height - 38.0, width: self.view.frame.width, height: 0.5))
        bottomLineView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        self.view.addSubview(bottomLineView)
        self.view.bringSubview(toFront: bottomLineView)
        
        // Draw refresh button
        self.refreshButton = UIButton(frame: CGRect(x: self.view.frame.width - 40.0 - 8.0, y: self.view.frame.height - 37.0, width: 40.0, height: 37.0))
        self.refreshButton.addTarget(self, action: #selector(PageViewController.refresh(_:)), for: UIControlEvents.touchUpInside)
        self.refreshButton.titleLabel?.textAlignment = .right
        self.refreshButton.titleLabel?.font = Constants.fontAwesome
        self.refreshButton.setTitle(Constants.fontAwesomeCodes["fa-refresh"]!, for: UIControlState())
        self.refreshButton.setTitleColor(UIColor.white, for: UIControlState())
        self.refreshButton.isEnabled = true
        self.view.addSubview(self.refreshButton)
        //-----------
        
        // Draw organiser button
        self.organiserButton = UIButton(frame: CGRect(x: 8.0, y: self.view.frame.height - 37.0, width: 40.0, height: 37.0))
        self.organiserButton.addTarget(self, action: #selector(PageViewController.organiser(_:)), for: UIControlEvents.touchUpInside)
        self.organiserButton.titleLabel?.textAlignment = .left
        self.organiserButton.titleLabel?.font = Constants.fontAwesome
        self.organiserButton.setTitle(Constants.fontAwesomeCodes["fa-bars"]!, for: UIControlState())
        self.organiserButton.setTitleColor(UIColor.white, for: UIControlState())
        self.organiserButton.isEnabled = true
        self.view.addSubview(self.organiserButton)
        //-----------
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = self.pages.index(of: viewController as! LocationViewController)!
        if currentIndex == self.pages.count-1 {
            return nil
        }
        let nextIndex = currentIndex + 1
        return self.pages[nextIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let currentIndex = self.pages.index(of: viewController as! LocationViewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = currentIndex - 1
        return self.pages[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.pendingIndex = self.pages.index(of: pendingViewControllers.first! as! LocationViewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.currentIndex = self.pendingIndex
            if let index = self.currentIndex {
                SettingsManager.setPageIndex(index: index)
                self.pageControl.currentPage = index
            }
        }
    }

    @objc func goToPageViewIndex(_ notification: Notification) {

        if let dict = (notification as NSNotification).userInfo as? Dictionary<String, AnyObject> {
            if self.checkForDataSourceChanges() == true {
                self.pageControl.numberOfPages = self.pages.count

                if let index = dict["pageIndex"] as? Int {
                    var direction: UIPageViewControllerNavigationDirection
                    if index < self.currentIndex {
                        direction = .reverse
                    } else {
                        direction = .forward
                    }
                    self.currentIndex = index
                    
                    DispatchQueue.main.async {
                        SettingsManager.setPageIndex(index: index)
                        
                        self.pageControl.currentPage = index
                        self.pageControl.numberOfPages = self.pages.count
                        self.pageContainer.setViewControllers([self.pages[index]], direction: direction, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    SettingsManager.setPageIndex(index: 0)

                    self.currentIndex = 0
                    self.pageControl.currentPage = 0
                    self.pageContainer.setViewControllers([self.pages[0]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
                }
            }
        }
    }

    @objc func backFromOrganiser(_ notification: Notification) {
        if self.checkForDataSourceChanges() == true {
            self.pageControl.numberOfPages = self.pages.count
            
            DispatchQueue.main.async {
                self.pageControl.currentPage = self.currentIndex!
                self.pageContainer.setViewControllers([self.pages[self.pageControl.currentPage]], direction: .forward, animated: false, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                SettingsManager.setPageIndex(index: 0)

                self.currentIndex = 0
                self.pageControl.currentPage = 0
                self.pageContainer.setViewControllers([self.pages[0]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)
            }
        }
    }

    func checkForDataSourceChanges() -> Bool {

        let currentLocation = self.pages.first!

        let oldPages = self.pages
        self.pages.removeAll()
        self.pages.append(currentLocation)
        
        // Make fetch request to get all saved locations
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ForecastLocation")
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            let newLocations = results as! [NSManagedObject]

            for newLocation in newLocations {
                guard let index = newLocation.value(forKey: "index") as? NSNumber else {
                    continue
                }

                guard let fullNameString = newLocation.value(forKey: "fullName") as? String else {
                    continue
                }

                guard let displayNameString = newLocation.value(forKey: "name") as? String else {
                    continue
                }

                let location = oldPages.filter{ $0.locationName == fullNameString}.first

                // if the location has been previously created
                if let location = location {
                    self.pages.insert(location, at: Int(truncating: index))
                } else {
                    let locationViewController = self.storyboard!.instantiateViewController(withIdentifier: "locationViewController") as! LocationViewController
                    locationViewController.locationName = fullNameString
                    locationViewController.displayName = displayNameString
                    locationViewController.isCurrentLocation = false
                    self.pages.insert(locationViewController, at: Int(truncating: index))
                }
            }
            
            self.savedLocations = newLocations
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            
            return false
        }

        return true
    }

    @objc func organiser(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let organiserViewController = storyboard.instantiateViewController(withIdentifier: "organiserViewController") as! OrganiserViewController
        organiserViewController.modalPresentationStyle = .overFullScreen
        self.view.window?.rootViewController?.present(organiserViewController, animated: true, completion: nil)
    }

    @objc func refresh(_ sender: AnyObject) {
        let currentViewController = self.pages[self.pageControl.currentPage]
        currentViewController.refresh()
    }
    
    func fetchLocations() {
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

            self.savedLocations = []
            self.currentIndex = 0
        }
    }
    
    func initLocations() {
        let currentLocation = self.storyboard!.instantiateViewController(withIdentifier: "locationViewController") as! LocationViewController
        currentLocation.locationName = nil
        currentLocation.isCurrentLocation = true
        self.pages.append(currentLocation)

        for location in self.savedLocations {
            guard let fullName = location.value(forKey: "fullName") as? String else {
                continue
            }

            guard let displayName = location.value(forKey: "name") as? String else {
                continue
            }

            let locationViewController = self.storyboard!.instantiateViewController(withIdentifier: "locationViewController") as! LocationViewController
            locationViewController.locationName = fullName
            locationViewController.displayName = displayName
            locationViewController.isCurrentLocation = false
            self.pages.append(locationViewController)
        }
    }
}
