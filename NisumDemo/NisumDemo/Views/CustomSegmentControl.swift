//
//  CustomSegmentControl.swift
//  NisumDemo
//
//  Created by Khurram Iqbal on 27/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class CustomSegmentControl: UISegmentedControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tintColor = UIColor.clear
        self.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.gray], for: .normal)
        self.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.customBlueColor()], for: .selected)
    }
}
