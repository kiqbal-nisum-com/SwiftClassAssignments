//
//  BinModel+CoreDataProperties.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 21/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import Foundation
import CoreData


extension BinModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BinModel> {
        return NSFetchRequest<BinModel>(entityName: "BinModel")
    }

    @NSManaged public var binToLocation: LocationModel?
    @NSManaged public var binToItem: NSSet?
    
    func setBin (binDict : [String : Any],context:NSManagedObjectContext){
        self.name = binDict["name"] as! String
        self.entityTypeModel = CoreDataModelName.BinModel.rawValue
        self.id  = binDict["id"] as! Int16
        self.binToLocation = CoreDataManager.shared.fetechRequest(entityName: CoreDataModelName.LocationModel.rawValue, predicate: NSPredicate(format: "id == %d", binDict["locationId"] as! Int16),context: context)?.first as? LocationModel
        
    
    }

}

// MARK: Generated accessors for binToItem
extension BinModel {

    @objc(addBinToItemObject:)
    @NSManaged public func addToBinToItem(_ value: ItemModel)

    @objc(removeBinToItemObject:)
    @NSManaged public func removeFromBinToItem(_ value: ItemModel)

    @objc(addBinToItem:)
    @NSManaged public func addToBinToItem(_ values: NSSet)

    @objc(removeBinToItem:)
    @NSManaged public func removeFromBinToItem(_ values: NSSet)

}
