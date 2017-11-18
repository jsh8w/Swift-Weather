//
//  ForecastDetailsView.swift
//  Weather
//
//  Created by James Shaw on 30/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import WeatherFrontKit

class ForecastDetailsView: UIView {

    var feelsLikelabel: UILabel!
    var feelsLikeValuelabel: UILabel!
    var feelsLikeIconLabel: UILabel!
    var precipitationlabel: UILabel!
    var precipitationValuelabel: UILabel!
    var precipitationIconLabel: UILabel!
    var dewPointlabel: UILabel!
    var dewPointValuelabel: UILabel!
    var dewPointIconLabel: UILabel!
    var humiditylabel: UILabel!
    var humidityValuelabel: UILabel!
    var humidityIconLabel: UILabel!
    var sunriselabel: UILabel!
    var sunriseValuelabel: UILabel!
    var sunriseIconLabel: UILabel!
    var sunsetlabel: UILabel!
    var sunsetValuelabel: UILabel!
    var sunsetIconLabel: UILabel!
    var windlabel: UILabel!
    var windValuelabel: UILabel!
    var windIconLabel: UILabel!
    var cloudCoverlabel: UILabel!
    var cloudCoverValuelabel: UILabel!
    var cloudCoverIconLabel: UILabel!

    let labelColour = UIColor.white

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.drawLabels(Int(frame.width), height: Int(frame.height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawLabels(_ width: Int, height: Int) {

        let xMargin = 10
        let yMargin = 8
        let ySpacing = 8
        let iconLabelWidth = 30
        let valueLabelWidth = 35
        let noOfLabelsHigh = 4
        let labelHeight = (height - (yMargin * 2) - ((noOfLabelsHigh - 1) * ySpacing)) / noOfLabelsHigh

        self.feelsLikeValuelabel = UILabel(frame: CGRect(x: (width / 2) - (valueLabelWidth + xMargin), y: yMargin, width: valueLabelWidth, height: labelHeight))
        self.feelsLikeValuelabel.text = "0°"
        self.feelsLikeValuelabel.textAlignment = .right
        self.feelsLikeValuelabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
        self.feelsLikeValuelabel.adjustsFontSizeToFitWidth = true
        self.feelsLikeValuelabel.textColor = self.labelColour
        self.addSubview(self.feelsLikeValuelabel)

        self.feelsLikeIconLabel = UILabel(frame: CGRect(x: xMargin, y: yMargin, width: iconLabelWidth, height: labelHeight))
        self.feelsLikeIconLabel.attributedText = createAttributedString("temperature", fontSize: 14.0)
        self.feelsLikeIconLabel.textAlignment = .center
        self.feelsLikeIconLabel.adjustsFontSizeToFitWidth = true
        self.feelsLikeIconLabel.textColor = self.labelColour
        self.addSubview(self.feelsLikeIconLabel)

        self.feelsLikelabel = UILabel(frame: CGRect(x: xMargin + Int(self.feelsLikeIconLabel.frame.width), y: yMargin, width: Int(self.feelsLikeValuelabel.frame.origin.x) - xMargin - Int(self.feelsLikeIconLabel.frame.width), height: labelHeight))
        self.feelsLikelabel.text = "Cloud Cover"
        self.feelsLikelabel.textAlignment = .left
        self.feelsLikelabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
        self.feelsLikelabel.adjustsFontSizeToFitWidth = true
        self.feelsLikelabel.textColor = self.labelColour
        self.addSubview(self.feelsLikelabel)

        let cloudCoverLabelFontSize = self.getApproximateAdjustedFontSizeWithLabel(self.feelsLikelabel)
        self.feelsLikelabel.text = "Feels Like"
        self.feelsLikeValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.feelsLikeIconLabel.attributedText = createAttributedString("temperature", fontSize: cloudCoverLabelFontSize)

        self.precipitationValuelabel = UILabel(frame: CGRect(x: Int(self.feelsLikeValuelabel.frame.origin.x), y: Int(self.feelsLikeValuelabel.frame.origin.y) + labelHeight + ySpacing, width: Int(self.feelsLikeValuelabel.frame.width), height: labelHeight))
        self.precipitationValuelabel.text = "0%"
        self.precipitationValuelabel.textAlignment = .right
        self.precipitationValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.precipitationValuelabel.adjustsFontSizeToFitWidth = true
        self.precipitationValuelabel.textColor = self.labelColour
        self.addSubview(self.precipitationValuelabel)

        self.precipitationlabel = UILabel(frame: CGRect(x: Int(self.feelsLikelabel.frame.origin.x), y: Int(self.feelsLikelabel.frame.origin.y) + labelHeight + ySpacing, width: Int(self.feelsLikelabel.frame.width), height: labelHeight))
        self.precipitationlabel.text = "Precipitation"
        self.precipitationlabel.textAlignment = .left
        self.precipitationlabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.precipitationlabel.adjustsFontSizeToFitWidth = true
        self.precipitationlabel.textColor = self.labelColour
        self.addSubview(self.precipitationlabel)

        self.precipitationIconLabel = UILabel(frame: CGRect(x: xMargin, y: Int(self.feelsLikeValuelabel.frame.origin.y) + labelHeight + ySpacing, width: iconLabelWidth, height: labelHeight))
        self.precipitationIconLabel.attributedText = createAttributedString("umbrella", fontSize: cloudCoverLabelFontSize)
        self.precipitationIconLabel.textAlignment = .center
        self.precipitationIconLabel.adjustsFontSizeToFitWidth = true
        self.precipitationIconLabel.textColor = self.labelColour
        self.addSubview(self.precipitationIconLabel)

        self.dewPointValuelabel = UILabel(frame: CGRect(x: Int(self.precipitationValuelabel.frame.origin.x), y: Int(self.precipitationValuelabel.frame.origin.y) + labelHeight + ySpacing, width: Int(self.precipitationValuelabel.frame.width), height: labelHeight))
        self.dewPointValuelabel.text = "0°"
        self.dewPointValuelabel.textAlignment = .right
        self.dewPointValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.dewPointValuelabel.adjustsFontSizeToFitWidth = true
        self.dewPointValuelabel.textColor = self.labelColour
        self.addSubview(self.dewPointValuelabel)

        self.dewPointlabel = UILabel(frame: CGRect(x: Int(self.precipitationlabel.frame.origin.x), y: Int(self.precipitationlabel.frame.origin.y) + labelHeight + ySpacing, width: Int(self.precipitationlabel.frame.width), height: labelHeight))
        self.dewPointlabel.text = "Dew Point"
        self.dewPointlabel.textAlignment = .left
        self.dewPointlabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.dewPointlabel.adjustsFontSizeToFitWidth = true
        self.dewPointlabel.textColor = self.labelColour
        self.addSubview(self.dewPointlabel)

        self.dewPointIconLabel = UILabel(frame: CGRect(x: xMargin, y: Int(self.precipitationValuelabel.frame.origin.y) + labelHeight + ySpacing, width: iconLabelWidth, height: labelHeight))
        self.dewPointIconLabel.attributedText = createAttributedString("dew-point", fontSize: cloudCoverLabelFontSize+4.0)
        self.dewPointIconLabel.textAlignment = .center
        self.dewPointIconLabel.adjustsFontSizeToFitWidth = true
        self.dewPointIconLabel.textColor = self.labelColour
        self.addSubview(self.dewPointIconLabel)

        self.humidityValuelabel = UILabel(frame: CGRect(x: Int(self.dewPointValuelabel.frame.origin.x), y: Int(self.dewPointValuelabel.frame.origin.y) + labelHeight + ySpacing, width: Int(self.dewPointValuelabel.frame.width), height: labelHeight))
        self.humidityValuelabel.text = "0%"
        self.humidityValuelabel.textAlignment = .right
        self.humidityValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.humidityValuelabel.adjustsFontSizeToFitWidth = true
        self.humidityValuelabel.textColor = self.labelColour
        self.addSubview(self.humidityValuelabel)

        self.humiditylabel = UILabel(frame: CGRect(x: Int(self.dewPointlabel.frame.origin.x), y: Int(self.dewPointlabel.frame.origin.y) + labelHeight + ySpacing, width: Int(self.dewPointlabel.frame.width), height: labelHeight))
        self.humiditylabel.text = "Humidity"
        self.humiditylabel.textAlignment = .left
        self.humiditylabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.humiditylabel.adjustsFontSizeToFitWidth = true
        self.humiditylabel.textColor = self.labelColour
        self.addSubview(self.humiditylabel)

        self.humidityIconLabel = UILabel(frame: CGRect(x: xMargin, y: Int(self.dewPointValuelabel.frame.origin.y) + labelHeight + ySpacing, width: iconLabelWidth, height: labelHeight))
        self.humidityIconLabel.attributedText = createAttributedString("humidity", fontSize: cloudCoverLabelFontSize)
        self.humidityIconLabel.textAlignment = .center
        self.humidityIconLabel.adjustsFontSizeToFitWidth = true
        self.humidityIconLabel.textColor = self.labelColour
        self.addSubview(self.humidityIconLabel)

        self.sunriseIconLabel = UILabel(frame: CGRect(x: (width / 2) + xMargin, y: Int(self.feelsLikeIconLabel.frame.origin.y), width: iconLabelWidth, height: labelHeight))
        self.sunriseIconLabel.attributedText = createAttributedString("sunrise", fontSize: cloudCoverLabelFontSize)
        self.sunriseIconLabel.textAlignment = .center
        self.sunriseIconLabel.adjustsFontSizeToFitWidth = true
        self.sunriseIconLabel.textColor = self.labelColour
        self.addSubview(self.sunriseIconLabel)

        self.sunriseValuelabel = UILabel(frame: CGRect(x: width - (valueLabelWidth + (xMargin * 2)), y: Int(self.feelsLikeValuelabel.frame.origin.y), width: valueLabelWidth, height: labelHeight))
        self.sunriseValuelabel.text = "00:00"
        self.sunriseValuelabel.textAlignment = .right
        self.sunriseValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.sunriseValuelabel.adjustsFontSizeToFitWidth = true
        self.sunriseValuelabel.textColor = self.labelColour
        self.addSubview(self.sunriseValuelabel)

        self.sunriselabel = UILabel(frame: CGRect(x: (width / 2) + xMargin + Int(self.sunriseIconLabel.frame.width), y: Int(self.feelsLikelabel.frame.origin.y), width: (width / 2) - xMargin - Int(self.sunriseIconLabel.frame.width) - Int(self.sunriseValuelabel.frame.width), height: labelHeight))
        self.sunriselabel.text = "Sunrise"
        self.sunriselabel.textAlignment = .left
        self.sunriselabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.sunriselabel.adjustsFontSizeToFitWidth = true
        self.sunriselabel.textColor = self.labelColour
        self.addSubview(self.sunriselabel)

        self.sunsetValuelabel = UILabel(frame: CGRect(x: Int(self.sunriseValuelabel.frame.origin.x), y: Int(self.precipitationValuelabel.frame.origin.y), width: Int(self.sunriseValuelabel.frame.width), height: labelHeight))
        self.sunsetValuelabel.text = "00:00"
        self.sunsetValuelabel.textAlignment = .right
        self.sunsetValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.sunsetValuelabel.adjustsFontSizeToFitWidth = true
        self.sunsetValuelabel.textColor = self.labelColour
        self.addSubview(self.sunsetValuelabel)

        self.sunsetlabel = UILabel(frame: CGRect(x: Int(self.sunriselabel.frame.origin.x), y: Int(self.precipitationlabel.frame.origin.y), width: Int(self.sunriselabel.frame.width), height: labelHeight))
        self.sunsetlabel.text = "Sunset"
        self.sunsetlabel.textAlignment = .left
        self.sunsetlabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.sunsetlabel.adjustsFontSizeToFitWidth = true
        self.sunsetlabel.textColor = self.labelColour
        self.addSubview(self.sunsetlabel)

        self.sunsetIconLabel = UILabel(frame: CGRect(x: Int(self.sunriseIconLabel.frame.origin.x), y: Int(self.precipitationIconLabel.frame.origin.y), width: iconLabelWidth, height: labelHeight))
        self.sunsetIconLabel.attributedText = createAttributedString("sunset", fontSize: cloudCoverLabelFontSize)
        self.sunsetIconLabel.textAlignment = .center
        self.sunsetIconLabel.adjustsFontSizeToFitWidth = true
        self.sunsetIconLabel.textColor = self.labelColour
        self.addSubview(self.sunsetIconLabel)

        self.cloudCoverValuelabel = UILabel(frame: CGRect(x: Int(self.sunsetValuelabel.frame.origin.x), y: Int(self.dewPointValuelabel.frame.origin.y), width: Int(self.sunsetValuelabel.frame.width), height: labelHeight))
        self.cloudCoverValuelabel.text = "50%"
        self.cloudCoverValuelabel.textAlignment = .right
        self.cloudCoverValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.cloudCoverValuelabel.adjustsFontSizeToFitWidth = true
        self.cloudCoverValuelabel.textColor = self.labelColour
        self.addSubview(self.cloudCoverValuelabel)

        self.cloudCoverlabel = UILabel(frame: CGRect(x: Int(self.sunsetlabel.frame.origin.x), y: Int(self.dewPointlabel.frame.origin.y), width: Int(self.sunsetlabel.frame.width), height: labelHeight))
        self.cloudCoverlabel.text = "Cloud Cover"
        self.cloudCoverlabel.textAlignment = .left
        self.cloudCoverlabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.cloudCoverlabel.adjustsFontSizeToFitWidth = true
        self.cloudCoverlabel.textColor = self.labelColour
        self.addSubview(self.cloudCoverlabel)

        self.cloudCoverIconLabel = UILabel(frame: CGRect(x: Int(self.sunsetIconLabel.frame.origin.x), y: Int(self.dewPointIconLabel.frame.origin.y), width: iconLabelWidth, height: labelHeight))
        self.cloudCoverIconLabel.attributedText = createAttributedString("cloud-cover", fontSize: cloudCoverLabelFontSize)
        self.cloudCoverIconLabel.textAlignment = .center
        self.cloudCoverIconLabel.adjustsFontSizeToFitWidth = true
        self.cloudCoverIconLabel.textColor = self.labelColour
        self.addSubview(self.cloudCoverIconLabel)

        self.windValuelabel = UILabel(frame: CGRect(x: Int(self.cloudCoverValuelabel.frame.origin.x), y: Int(self.humidityValuelabel.frame.origin.y), width: Int(self.cloudCoverValuelabel.frame.width), height: labelHeight))
        self.windValuelabel.text = "0N"
        self.windValuelabel.textAlignment = .right
        self.windValuelabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.windValuelabel.adjustsFontSizeToFitWidth = true
        self.windValuelabel.textColor = self.labelColour
        self.addSubview(self.windValuelabel)

        self.windlabel = UILabel(frame: CGRect(x: Int(self.cloudCoverlabel.frame.origin.x), y: Int(self.humiditylabel.frame.origin.y), width: Int(self.cloudCoverlabel.frame.width), height: labelHeight))
        self.windlabel.text = "Wind"
        self.windlabel.textAlignment = .left
        self.windlabel.font = UIFont.systemFont(ofSize: cloudCoverLabelFontSize, weight: UIFont.Weight.thin)
        self.windlabel.adjustsFontSizeToFitWidth = true
        self.windlabel.textColor = self.labelColour
        self.addSubview(self.windlabel)

        self.windIconLabel = UILabel(frame: CGRect(x: Int(self.cloudCoverIconLabel.frame.origin.x), y: Int(self.humidityIconLabel.frame.origin.y), width: iconLabelWidth, height: labelHeight))
        self.windIconLabel.attributedText = createAttributedString("wind-detail", fontSize: cloudCoverLabelFontSize)
        self.windIconLabel.textAlignment = .center
        self.windIconLabel.adjustsFontSizeToFitWidth = true
        self.windIconLabel.textColor = self.labelColour
        self.addSubview(self.windIconLabel)
    }
    
    // Returns the font size of a label after it has been shrunk
    func getApproximateAdjustedFontSizeWithLabel(_ label: UILabel) -> CGFloat {
        
        if label.adjustsFontSizeToFitWidth == true {
            var currentFont: UIFont = label.font
            let originalFontSize = currentFont.pointSize
            var currentSize: CGSize = (label.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: currentFont])
            
            while currentSize.width > label.frame.size.width && currentFont.pointSize > (originalFontSize * label.minimumScaleFactor) {
                currentFont = currentFont.withSize(currentFont.pointSize - 1)
                currentSize = (label.text! as NSString).size(withAttributes: [NSAttributedStringKey.font: currentFont])
            }
            return currentFont.pointSize

        } else {
            return label.font.pointSize
        }
    }
    
    // Constructs attributed string with icon
    func createAttributedString(_ iconString: String, fontSize: CGFloat) -> NSMutableAttributedString {
        
        let weatherFont = UIFont(name: "WeatherIcons-Regular", size: fontSize)
        let iconAttributes = [NSAttributedStringKey.font: weatherFont!, NSAttributedStringKey.foregroundColor: UIColor.white]
        let iconCode = Constants.forecastIcons[iconString]!
        let attributedString = NSMutableAttributedString(string: "\(iconCode)", attributes: iconAttributes)
        
        return attributedString
        
    }
}
