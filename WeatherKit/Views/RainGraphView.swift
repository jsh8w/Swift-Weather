//
//  RainGraphView.swift
//  Weather
//
//  Created by James Shaw on 25/05/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit

open class RainGraphView: UIView {

    open var graphPoints:[Float] = [] {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }

    var bottomLineView: UIView!

    let margin: CGFloat = 20.0
    let fadedWhiteColour = UIColor(white: 1.0, alpha: 0.7)

    open var noPrecipLabel: UILabel!
    var heavyLabel: UILabel!
    var mediumLabel: UILabel!
    var lightLabel: UILabel!
    
    // Minutely available for other countries i.e not US or UK
    open var minutelyAvailable: Bool = true
    
    // Bool indicating if the rainGraphView is in widget or app
    open var isWidget = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        let topBorder: CGFloat = 20.0
        let bottomBorder: CGFloat = 40.0
        let graphHeight = frame.height - topBorder - bottomBorder
        self.drawLabels(frame, graphHeight: graphHeight)

        self.bottomLineView = UIView(frame: CGRect(x: 0.0, y: frame.height, width: frame.width, height: 0.5))
        if self.isWidget == true {
            self.bottomLineView.backgroundColor = UIColor.darkGray
        }
        else {
            self.bottomLineView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        }
        self.addSubview(self.bottomLineView)
        self.bringSubview(toFront: self.bottomLineView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func draw(_ rect: CGRect) {

        if self.graphPoints.count > 0 || self.minutelyAvailable == false {

            let topBorder: CGFloat = 20.0
            let bottomBorder: CGFloat = 40.0
            let graphHeight = rect.height - topBorder - bottomBorder
            
            // Draw the graph
            self.drawGraph(rect, topBorder: topBorder, bottomBorder: bottomBorder, graphHeight: graphHeight)
            
            // Draw the X axis labels on graph
            self.drawXAxisLabels(rect, bottomBorder: bottomBorder)
            
            // Set label font
            self.setNoPrecipLabelFontAndFrame(rect, graphHeight: graphHeight)

            if self.isWidget == true {
                self.bottomLineView.backgroundColor = UIColor.darkGray
            }
            else {
                self.bottomLineView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
            }
        }

        self.bringSubview(toFront: self.heavyLabel)
        self.bringSubview(toFront: self.mediumLabel)
        self.bringSubview(toFront: self.lightLabel)

        self.heavyLabel.textColor = self.setIntensityLabelColor()
        self.mediumLabel.textColor = self.setIntensityLabelColor()
        self.lightLabel.textColor = self.setIntensityLabelColor()
    }
    
    func drawGraph(_ rect: CGRect, topBorder: CGFloat, bottomBorder: CGFloat, graphHeight: CGFloat) {

        let context = UIGraphicsGetCurrentContext()
        let width = rect.width
        let height = rect.height

        if self.minutelyAvailable == true {
            let maxValue: CGFloat = 1.0
            let lightValue: CGFloat = 0.1
            let mediumValue: CGFloat = 0.4
            let veryLightValue: CGFloat = 0.017

            let columnXPoint = { (column:Int) -> CGFloat in
                let spacer = (width - (self.margin * 2) - 4) / CGFloat((self.graphPoints.count - 1))
                var x: CGFloat = CGFloat(column) * spacer
                x += self.margin + 2
                
                return x
            }
            
            let columnYPoint = { (graphPoint: Float) -> CGFloat in
                var y: CGFloat = 0.0

                if graphPoint <= Float(veryLightValue) {
                    // Very light precipitation
                    y = (CGFloat(graphPoint) / veryLightValue) * (graphHeight/6)
                } else if graphPoint <= Float(lightValue) {
                    // Light precipitation
                    y = graphHeight/6
                    y += ((CGFloat(graphPoint) - veryLightValue) / (lightValue - veryLightValue)) * (graphHeight/6)
                } else if graphPoint <= Float(mediumValue) {
                    // Medium precipitation
                    y = graphHeight/3
                    y += ((CGFloat(graphPoint) - lightValue) / (mediumValue - lightValue)) * (graphHeight/3)

                } else {
                    // Heavy precipitation
                    y = (graphHeight/3) * 2
                    y += ((CGFloat(graphPoint) - mediumValue) / (maxValue - mediumValue)) * (graphHeight/3)
                }

                y = graphHeight + topBorder - y
                return y
            }

            if self.isWidget == true {
                UIColor.darkGray.setFill()
                UIColor.darkGray.setStroke()
            } else {
                UIColor.white.setFill()
                UIColor.white.setStroke()
            }

            let graphPath = UIBezierPath()
            graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(self.graphPoints[0])))
            for i in 1..<self.graphPoints.count {
                let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(self.graphPoints[i]))
                graphPath.addLine(to: nextPoint)
            }
            graphPath.lineWidth = 2.0
            graphPath.stroke()

            context?.saveGState()

            let clippingPath = graphPath.copy() as! UIBezierPath
            clippingPath.addLine(to: CGPoint(x: columnXPoint(self.graphPoints.count - 1), y: height))
            clippingPath.addLine(to: CGPoint(x: columnXPoint(0), y: height))
            clippingPath.close()
            clippingPath.addClip()

            let blueColour = UIColor(red: (95.0/255.0), green: (173.0/255.0), blue: (236.0/255.0), alpha: 1.0)
            blueColour.setFill()
            let rectPath = UIBezierPath(rect: CGRect(x: self.margin, y: topBorder, width: width - self.margin, height: height - bottomBorder - topBorder))
            rectPath.fill()
            
            context?.restoreGState()
        }
        
        // Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        // Top line
        linePath.move(to: CGPoint(x: self.margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - self.margin, y: topBorder))
        
        // 2nd line
        linePath.move(to: CGPoint(x: self.margin, y: (graphHeight/3) + topBorder))
        linePath.addLine(to: CGPoint(x: width - self.margin, y:(graphHeight/3) + topBorder))
        
        // 3nd line
        linePath.move(to: CGPoint(x: self.margin, y: ((graphHeight/3)*2) + topBorder))
        linePath.addLine(to: CGPoint(x: width - self.margin, y:((graphHeight/3)*2) + topBorder))
        
        var color = UIColor(white: 1.0, alpha: 0.5)
        if self.isWidget == true {
            color = UIColor.lightGray
        }
        color.setStroke()
        
        linePath.lineWidth = 0.5
        linePath.stroke()
        
        // X axis line
        let bottomLinePath = UIBezierPath()
        bottomLinePath.move(to: CGPoint(x: self.margin, y: height - bottomBorder))
        bottomLinePath.addLine(to: CGPoint(x: width - self.margin, y: height - bottomBorder))
        
        // Y axis line
        bottomLinePath.move(to: CGPoint(x: self.margin, y: topBorder))
        bottomLinePath.addLine(to: CGPoint(x: self.margin, y: (height - bottomBorder) + 1.0))
        
        // Add stroke to X and Y axis
        let bottomColor: UIColor!
        if self.isWidget == false {
            bottomColor = UIColor(white: 1.0, alpha: 1.0)
        } else {
            bottomColor = UIColor.darkGray
        }
        bottomColor.setStroke()
        bottomLinePath.lineWidth = 2.0
        bottomLinePath.stroke()
    }
    
    func drawXAxisLabels(_ rect: CGRect, bottomBorder: CGFloat) {

        for subview in self.subviews as [UIView] {
            if let label = subview as? UILabel {
                if label.tag >= 10000 {
                    label.removeFromSuperview()
                }
            }
        }

        let labelNumbers = [10, 20, 30, 40, 50]
        let x: CGFloat = (rect.width - (2 * self.margin)) / 6

        for (index, labelNumber) in labelNumbers.enumerated() {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            if labelNumber == 30 {
                label.text = "\(labelNumber) min"
            } else {
                label.text = "\(labelNumber)"
            }
            label.sizeToFit()
            label.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            if self.isWidget == true {
                label.textColor = UIColor.darkGray
            } else {
                label.textColor = self.fadedWhiteColour
            }
            label.center = CGPoint(x: (x * CGFloat(index + 1)) + self.margin, y: rect.height - bottomBorder + 16.0)
            label.textAlignment = NSTextAlignment.center
            label.tag = 10000 + index
            self.addSubview(label)

            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: (x * CGFloat(index + 1)) + self.margin, y: rect.height - bottomBorder))
            linePath.addLine(to: CGPoint(x: (x * CGFloat(index + 1)) + self.margin, y: rect.height - bottomBorder + 3.0))
            
            let color: UIColor!
            if self.isWidget == false {
                color = self.fadedWhiteColour
            } else {
                color = UIColor.darkGray
            }
            color.setStroke()
            
            linePath.lineWidth = 1.0
            linePath.stroke()
        }
    }
    
    func drawLabels(_ rect: CGRect, graphHeight: CGFloat) {
        
        // Create 'Heavy' Label
        self.heavyLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 21.0))
        self.heavyLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
        self.heavyLabel.textColor = self.setIntensityLabelColor()
        self.heavyLabel.text = "Heavy"
        self.heavyLabel.center = CGPoint(x: rect.width - self.margin - 25.0, y: (graphHeight/6) + 20.0)
        self.heavyLabel.textAlignment = NSTextAlignment.right
        self.addSubview(heavyLabel)
        //------------
        
        // Create 'Medium' Label
        self.mediumLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 21.0))
        self.mediumLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
        self.mediumLabel.textColor = self.setIntensityLabelColor()
        self.mediumLabel.textAlignment = NSTextAlignment.right
        self.mediumLabel.text = "Med"
        self.mediumLabel.center = CGPoint(x: rect.width - self.margin - 25.0, y: (graphHeight/2) + 20.0)
        self.addSubview(self.mediumLabel)
        //------------
        
        // Create 'Light' Label
        self.lightLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 21.0))
        self.lightLabel.text = "Light"
        self.lightLabel.font = UIFont.systemFont(ofSize: 10.0, weight: UIFont.Weight.semibold)
        self.lightLabel.textColor = self.setIntensityLabelColor()
        self.lightLabel.textAlignment = NSTextAlignment.right
        self.lightLabel.center = CGPoint(x: rect.width - self.margin - 25.0, y: ((graphHeight/6)*5) + 20.0)
        self.addSubview(self.lightLabel)
        //------------
        
        // Draw 'No precipitation' Label
        self.noPrecipLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 21.0))
        self.noPrecipLabel.text = "No Precipitation forecast this hour."
        self.setNoPrecipLabelFontAndFrame(rect, graphHeight: graphHeight)
        self.noPrecipLabel.textAlignment = NSTextAlignment.center
        self.addSubview(self.noPrecipLabel)
        self.noPrecipLabel.isHidden = true
        //------------
    }
    
    func setIntensityLabelColor() -> UIColor {
        if self.isWidget == false {
            return self.fadedWhiteColour
        } else {
            return UIColor.darkGray
        }
    }
    
    func setNoPrecipLabelFontAndFrame(_ rect: CGRect, graphHeight: CGFloat) {

        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        
        switch height {
        case 480.0:
            // iPhone 4s
            if self.isWidget == false {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            } else {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.thin)
            }
        case 568.0:
            // iPhone 5s
            if self.isWidget == false {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            } else {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.thin)
            }
        case 667.0:
            // iPhone 6s
            if self.isWidget == false {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
            } else {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            }
        case 736.0:
            // iPhone 6s+
            if self.isWidget == false {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.thin)
            } else {
                self.noPrecipLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.thin)
            }
        default:
            print("not an iPhone")
            
        }
        
        self.noPrecipLabel.sizeToFit()
        
        if self.isWidget == false {
            self.noPrecipLabel.textColor = UIColor.white
        } else {
            self.noPrecipLabel.textColor = UIColor.darkGray
        }
        self.noPrecipLabel.center = CGPoint(x: rect.width / 2.0, y: (graphHeight/2) + 20.0)
    }
}
