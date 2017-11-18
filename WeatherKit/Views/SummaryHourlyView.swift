//
//  SummaryHourlyView.swift
//  Weather
//
//  Created by James Shaw on 16/07/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit

open class SummaryHourlyView: UIView {

    open var dataPoints:[DataPoint]? {
        didSet {
            self.dataPointsSet()
        }
    }

    var x: CGFloat = 20.0
    var noOfCells = 24
    
    override open func draw(_ rect: CGRect) {
        self.updateCells(frame.width, height: frame.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        self.drawCells()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func dataPointsSet() {
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func drawCells() {
        for index in 0...(self.noOfCells-1) {
            let cell = UIView(frame: CGRect.zero)
            cell.backgroundColor = UIColor.clear
            cell.tag = index
            self.addSubview(cell)
        }
    }

    func updateCells(_ width: CGFloat, height: CGFloat) {

        self.x = 20.0

        guard let dataPoints = self.dataPoints else {
            return
        }

        let cellWidth: CGFloat = round((width - (2 * self.x)) / CGFloat(self.noOfCells))
        self.x = (width - (cellWidth * CGFloat(self.noOfCells))) / 2

        for index in 0...(self.noOfCells-1) {

            let startingIndex = self.noOfCells - dataPoints.count
            let rect = CGRect(x: self.x, y: 0.0, width: cellWidth, height: height)

            // Before the current time
            if index < startingIndex {

                var path: UIBezierPath?

                if index == 0 {
                    path = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.bottomLeft], cornerRadii: CGSize(width: 3.0, height: 3.0))
                } else if index == self.noOfCells-1 {
                    path = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.topRight, UIRectCorner.bottomRight], cornerRadii: CGSize(width: 3.0, height: 3.0))
                } else {
                    path = UIBezierPath(rect: rect)
                }

                UIColor(white: 1.0, alpha: 0.1).setFill()
                path!.fill()
            } else {

                let dataPointindex = index - startingIndex
                let dataPoint = dataPoints[dataPointindex]

                let colour = dataPoint.getRainColour()

                var path: UIBezierPath?

                if index == 0 {
                    path = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.bottomLeft], cornerRadii: CGSize(width: 3.0, height: 3.0))
                } else if index == self.noOfCells-1 {
                    path = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.topRight, UIRectCorner.bottomRight], cornerRadii: CGSize(width: 3.0, height: 3.0))
                } else {
                    path = UIBezierPath(rect: rect)
                }

                colour.setFill()
                path!.fill()
            }

            self.x += cellWidth
        }
    }
}
