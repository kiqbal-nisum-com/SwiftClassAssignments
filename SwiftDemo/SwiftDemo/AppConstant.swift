//
//  AppConstant.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 14/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class AppConstant: NSObject {
    
    //MARK: - Storyboard Identifiers
    static let backToBinControllerSegueIdentifier = "BackToBin"
    static let NewValueSegueIdentifier = "NewValueSegue"
    static let searchViewControllerSegueIdentifier = "SearchViewControllerSegue"
    
    
    //MARK: - Cell Identifiers
    
    static let searchViewControllerCellIdentifier = "SearchItemCell"
    
    //MARK: - Web Services URL
    
    static let baseURL = "http://localhost:3000/"
    static let allData = "db"
    static let binUrl = "bin"
    static let itemUrl = "Item"
    static let location = "location"
}
