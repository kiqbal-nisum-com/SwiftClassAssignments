//
//  customTextField.swift
//  NisumDemo
//
//  Created by Khurram Iqbal on 18/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    let blueColor = UIColor.blue.cgColor
    let greyColor = UIColor.lightGray.cgColor
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setView(color : CGColor){
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}


