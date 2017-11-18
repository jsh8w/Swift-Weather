//
//  TodayView.swift
//  Weather
//
//  Created by James Shaw on 03/08/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import WeatherFrontKit

class TodayView: UIView {
    var summaryHourlyView: SummaryHourlyView!
    var todayForecastView: TodayForecastView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.drawView(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawView(frame: CGRect) {

        self.backgroundColor = UIColor.clear
        
        // Constant
        let yBorder: CGFloat = 12.0
        
        // Create summary hourly view
        self.summaryHourlyView = SummaryHourlyView()
        self.summaryHourlyView.frame = CGRect(x: 0.0, y: yBorder, width: frame.width, height: 15.0)
        self.addSubview(self.summaryHourlyView)
        
        // Create TodayForecastView
        self.todayForecastView = TodayForecastView(frame: CGRect(x: 0.0, y: 1.0, width: frame.width, height: 118.0))
        self.todayForecastView.isWidget = true
        self.addSubview(self.todayForecastView)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
}
