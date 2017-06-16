//
//  BinLocModel.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 14/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

enum EntityType  {
    
    case ItemType
    case BinType
    case LocationType
    
    
}
class BinLocModel: NSObject {
   
    var items : [Item]! = [Item]()
    var names : [String]! = [String]()
    var bins : [String]! = [String]()
    var locations : [String]! = [String]()
    var modelType : EntityType = .BinType
    
    func addElement(name : String? ){
        if name == nil {return}
        
        switch (modelType){
        
        case EntityType.BinType : self.bins.append(name!)
        case EntityType.LocationType : self.locations.append(name!)
        default : break
        }
    }
    
    func setName (){
        names = (modelType == .BinType) ? bins : locations
    }
    func getIndexOfValue(val : String!)-> Int{
    
      return  names.index(of: val)!
    }
}
