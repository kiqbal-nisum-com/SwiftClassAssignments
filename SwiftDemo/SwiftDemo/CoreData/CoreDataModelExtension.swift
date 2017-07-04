//
//  CoreDataModelExtension.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 30/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import Foundation
import CoreData

extension EntityBaseModel {
    func setObjectProperties(jsonDict : [String : Any]!,entityType : String,context : NSManagedObjectContext){
            self.name = jsonDict["name"] as? String
            self.id  = jsonDict["id"] as! Int16
            self.entityTypeModel =  entityType
            self.setEntityObject(jsonDict: jsonDict, entityType: EntityType(rawValue: entityType)!, context: context)
        }
    
    func setEntityObject(jsonDict :  [String : Any]! ,entityType : EntityType,context : NSManagedObjectContext){
        switch (entityType){
        case .Bin:  (self as! BinModel).binToLocation = CoreDataManager.shared.fetechRequestElement(entityName: CoreDataModelName.LocationModel.rawValue, predicate: NSPredicate(format: "id == %d", jsonDict["locationId"] as! Int16),context: context)

        case .Item:  (self as! ItemModel).iItemToBin = CoreDataManager.shared.fetechRequestElement(entityName: CoreDataModelName.BinModel.rawValue, predicate: NSPredicate(format: "id == %d", jsonDict["binId"] as! Int16),context: context); (self as! ItemModel).qty = jsonDict["quantity"] as! Int16
        default : break
        }
    }
    
    func getObjectId(entityName : String,context : NSManagedObjectContext)->Int16{
        guard let entityId : NSArray = (CoreDataManager.shared.fetechRequestElements(entityName: "entityName", predicate: nil, context: context)) else{
            return 1
        }
        return Int16(entityId.count + 1)
    }
}
