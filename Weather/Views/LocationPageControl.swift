//
//  LocationPageControl.swift
//  Weather
//
//  Created by James Shaw on 07/07/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import WeatherFrontKit

class LocationPageControl: UIPageControl {
    
    override var currentPage: Int {
        didSet {
            self.updateDots()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateDots() {
        for i in 0 ..< self.subviews.count {
            let view: UIView = self.subviews[i]
            
            // Current location dot
            if i == 0 {
                self.pageIndicatorTintColor = UIColor.clear
                self.currentPageIndicatorTintColor = UIColor.clear
                
                // if label hasn't already been created
                if view.subviews.count == 0 {
                    let locationIconLabel = UILabel(frame: CGRect(x: -2.5, y: -2.5, width: 11.0, height: 10.0))
                    locationIconLabel.font = UIFont(name: "FontAwesome", size: 12.0)
                    locationIconLabel.textAlignment = .center
                    locationIconLabel.textColor = self.currentPage == i ? UIColor.white : UIColor.lightGray
                    locationIconLabel.text = Constants.fontAwesomeCodes["fa-location-arrow"]
                    view.addSubview(locationIconLabel)
                } else {
                    let locationIconLabel = view.subviews.first as! UILabel
                    locationIconLabel.textColor = self.currentPage == i ? UIColor.white : UIColor.lightGray
                }
            } else {
                if self.currentPage == i {
                    view.backgroundColor = UIColor.white
                } else {
                    view.backgroundColor = UIColor.lightGray
                }
            }
        }
    }
}
