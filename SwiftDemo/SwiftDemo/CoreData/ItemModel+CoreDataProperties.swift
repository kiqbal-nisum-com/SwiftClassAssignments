//
//  ItemModel+CoreDataProperties.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 21/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import Foundation
import CoreData


extension ItemModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemModel> {
        return NSFetchRequest<ItemModel>(entityName: "ItemModel")
    }

    @NSManaged public var qty: Int16
    @NSManaged public var iItemToBin: BinModel!
    
    func setItem(itemDic : [String : Any],context:NSManagedObjectContext){
    
        self.qty = itemDic["qty"] as! Int16
        self.name = itemDic["name"] as! String
        self.entityTypeModel = CoreDataModelName.ItemModel.rawValue
        self.id  = itemDic["id"] as! Int16
        self.iItemToBin = CoreDataManager.shared.fetechRequest(entityName: CoreDataModelName.BinModel.rawValue, predicate: NSPredicate(format: "id == %d", itemDic["binId"] as! Int16),context: context)?.first as! BinModel
    }

}
