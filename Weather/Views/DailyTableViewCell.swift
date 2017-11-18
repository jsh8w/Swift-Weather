//
//  DailyTableViewCell.swift
//  Weather
//
//  Created by James Shaw on 17/06/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import WeatherFrontKit

class DailyTableViewCell: UITableViewCell {
    
    // SummaryView
    var summaryView: UIView!
    var dayLabel: UILabel!
    var barView: UIView!
    var minTempLabel: UILabel!
    var maxTempLabel: UILabel!
    //------------
    
    var todayForecastView: TodayForecastView!
    var summaryHourlyView: SummaryHourlyView!
    
    // Separator
    var bottomLineView: UIView!
    
    // Bool indicating if summary or todayForecastView is showing
    var summaryShowing = true
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clear

        self.summaryView = UIView(frame: CGRect.zero)
        self.summaryView.backgroundColor = UIColor.clear
        self.summaryView.alpha = 1.0
        self.contentView.addSubview(self.summaryView)

        self.dayLabel = UILabel(frame: CGRect.zero)
        self.dayLabel.textColor = UIColor.white
        self.dayLabel.textAlignment = .left
        self.dayLabel.backgroundColor = UIColor.clear
        self.summaryView.addSubview(self.dayLabel)

        self.minTempLabel = UILabel(frame: CGRect.zero)
        self.minTempLabel.textColor = UIColor.white
        self.minTempLabel.textAlignment = .left
        self.minTempLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
        self.minTempLabel.sizeToFit()
        self.minTempLabel.backgroundColor = UIColor.clear
        self.summaryView.addSubview(self.minTempLabel)

        self.maxTempLabel = UILabel(frame: CGRect.zero)
        self.maxTempLabel.textColor = UIColor.white
        self.maxTempLabel.textAlignment = .right
        self.maxTempLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
        self.maxTempLabel.sizeToFit()
        self.maxTempLabel.backgroundColor = UIColor.clear
        self.summaryView.addSubview(self.maxTempLabel)

        self.barView = UIView(frame: CGRect.zero)
        self.barView.backgroundColor = UIColor.white
        self.barView.alpha = 0.1
        self.barView.layer.cornerRadius = 2.5
        self.barView.clipsToBounds = true
        self.summaryView.addSubview(self.barView)

        self.summaryHourlyView = SummaryHourlyView()
        self.summaryView.addSubview(self.summaryHourlyView)

        self.todayForecastView = TodayForecastView()
        self.todayForecastView.alpha = 0.0
        self.contentView.addSubview(self.todayForecastView)

        self.bottomLineView = UIView(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        self.contentView.addSubview(self.bottomLineView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.minTempLabel.sizeToFit()
        self.maxTempLabel.sizeToFit()

        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
            // iPhone 4s
            self.dayLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
        case 568.0:
            // iPhone 5s
            self.dayLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
        case 667.0:
            // iPhone 6s
            self.dayLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
        case 736.0:
            // iPhone 6s+
            self.dayLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.thin)
        default:
            print("not an iPhone")
        }

        let xBorder: CGFloat = 20.0
        let yBorder: CGFloat = 12.0

        self.summaryView.frame = self.contentView.frame
        self.summaryHourlyView.frame = CGRect(x: 0.0, y: self.summaryView.frame.height - 15.0 - yBorder, width: self.summaryView.frame.width, height: 15.0)
        self.dayLabel.frame = CGRect(x: xBorder, y: 0.0, width: self.summaryView.frame.width/2 - xBorder, height: self.summaryHourlyView.frame.origin.y)

        let maxTempLabelX = self.summaryView.frame.width - xBorder - self.maxTempLabel.frame.width
        self.maxTempLabel.frame.origin = CGPoint(x: maxTempLabelX, y: self.dayLabel.center.y - (self.maxTempLabel.frame.height / 2))

        let minTempLabelX = self.summaryView.center.x + 20.0
        self.minTempLabel.frame.origin = CGPoint(x: minTempLabelX, y: self.dayLabel.center.y - (self.minTempLabel.frame.height / 2))

        let barX = self.minTempLabel.frame.origin.x + self.minTempLabel.frame.width + 8.0
        let barWidth = self.maxTempLabel.frame.origin.x - barX - 8.0
        let barHeight: CGFloat = 8.0
        let barY = (self.summaryHourlyView.frame.origin.y/2) - (barHeight / 2)
        let rect = CGRect(x: barX, y: barY, width: barWidth, height: barHeight)
        self.barView.frame = rect

        self.todayForecastView.frame = CGRect(x: 0.0, y: 1.0, width: self.contentView.frame.width, height: 118.0)

        let yLine = self.contentView.frame.height - 0.5
        self.bottomLineView.frame = CGRect(x: 0.0, y: yLine, width: self.contentView.frame.width, height: 0.5)
    }
}
