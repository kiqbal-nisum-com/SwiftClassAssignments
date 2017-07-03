//
//  BinLocModel.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 14/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit


class BinLocModel: NSObject {
   
    var items : [EntityProtocol]! = [EntityProtocol]()
    var names : [String]! = [String]()
    var bins : [String]! = [String]()
    var locations : [String]! = [String]()
    var modelType : EntityType = .Bin
    
    var entityBaseModel : [EntityBaseModel]?
    
    func addElement(name : String? ){
        if name == nil {return}
        
        switch (modelType){
        
        case EntityType.Bin : self.bins.append(name!)
        case EntityType.Location : self.locations.append(name!)
        default : break
        }
    }
    
    func setName (){
        names = (modelType == .Bin) ? bins : locations
    }
    func getIndexOfValue(val : String!)-> Int{
    
      return  names.index(of: val)!
    }
   
    
    
    func loadMockData(){
        
        self.modelType = .Bin
        self.addElement(name: "bin 1")
        self.addElement(name: "bin 2")
        self.addElement(name: "bin 3")
        
        self.modelType = .Location
        self.addElement(name: "loc 1")
        self.addElement(name: "loc 2")
        self.addElement(name: "loc 3")
        
        self.items.append(Item(itemnName: "item1", bin: Bin(binName: "bin1", location:Location(locationName: "loc1")),qty : "1"))
        self.items.append(Item(itemnName: "item2", bin: Bin(binName: "bin2", location:Location(locationName: "loc2")),qty : "1"))
        self.items.append(Item(itemnName: "item3", bin: Bin(binName: "bin3", location:Location(locationName: "loc3")),qty : "1"))
        self.items.append(Item(itemnName: "Mock1", bin: Bin(binName: "bin1", location:Location(locationName: "loc1")),qty : "1"))
        
        
        self.items.append(Bin(binName: "bin1", location:Location(locationName: "loc1")))
        self.items.append(Bin(binName: "bin2", location:Location(locationName: "loc2")))
        self.items.append(Bin(binName: "bin3", location:Location(locationName: "loc3")))
        
        self.items.append(Location(locationName: "loc1"))
        self.items.append(Location(locationName: "loc2"))
        self.items.append(Location(locationName: "loc3"))
        
        
    }
    
    func getAllEntityBaseModel(){
    
        self.entityBaseModel  =  CoreDataManager.shared.fetechRequestElements(entityName: CoreDataModelName.EntityBaseModel.rawValue, predicate: nil, context: CoreDataManager.shared.viewContext)
    }
}
