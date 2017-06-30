//
//  Bin.swift
//  SwiftDemo
//
//  Created by khurram iqbal on 15/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class Bin: EntityProtocol {
    var name: String?
    var entityType: EntityType {return .Bin}
     var location : Location?
    
    init(binName : String?, location : Location?){
        self.name = binName
        self.location = location
        
    }
     init() {
    }
    
    
}
