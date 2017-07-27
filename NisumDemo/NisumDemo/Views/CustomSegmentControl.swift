//
//  CustomSegmentControl.swift
//  NisumDemo
//
//  Created by Khurram Iqbal on 27/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class CustomSegmentControl: UISegmentedControl {

    
    var aniamteLayer : CALayer?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tintColor = UIColor.clear
        self.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.gray], for: .normal)
        self.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.customBlueColor()], for: .selected)
        
        aniamteLayer = CALayer()
        aniamteLayer!.frame =  CGRect(x: 0, y: self.frame.height - 1, width: self.frame.size.width / 2, height: 1.5)
        aniamteLayer!.backgroundColor = UIColor.customBlueColor().cgColor

        let bottomLayer = CALayer()
        bottomLayer.frame =  CGRect(x: 0, y: self.frame.height , width: self.frame.size.width , height: 2)
        //        layer.borderColor = UIColor.customBlueColor().cgColor
        bottomLayer.backgroundColor = UIColor.lightGray.cgColor

        self.layer.addSublayer(bottomLayer)
        self.layer.addSublayer(aniamteLayer!)

    }
    func animateBottomSlider(){

        UIView.animate(withDuration: 1) {
            self.aniamteLayer?.frame = CGRect(x:  0 + ( self.frame.width/2 * CGFloat(self.selectedSegmentIndex) ), y: self.frame.height - 1, width: self.frame.size.width / CGFloat(self.numberOfSegments), height: 1.5)
        }
    }
    
}
