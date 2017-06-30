//
//  Location.swift
//  SwiftDemo
//
//  Created by khurram iqbal on 15/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class Location:EntityProtocol {
    var name: String?
    var entityType: EntityType {return .Location}
    
    init(locationName : String?){
    
        self.name = locationName
    
    }

}
