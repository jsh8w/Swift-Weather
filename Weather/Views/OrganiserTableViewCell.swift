//
//  OrganiserTableViewCell.swift
//  Weather
//
//  Created by James Shaw on 24/06/2016.
//  Copyright © 2016 James Shaw. All rights reserved.
//

import UIKit
import WeatherFrontKit

class OrganiserTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var subNameLabel: UILabel!

    @IBOutlet weak var nameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subNameTrailingContraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundColor = UIColor.clear
    }
}
