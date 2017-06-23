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
    
        self.qty = itemDic["quantity"] as! Int16
        self.iItemToBin = itemDic["bin"] as! BinModel
        self.name = itemDic["name"] as! String
        self.entityTypeModel = CoreDataModelName.ItemModel.rawValue
        if let  count  = (CoreDataManager.shared.fetechRequest(entityName: CoreDataModelName.ItemModel.rawValue, predicate: nil,context: context)?.count)  {
            self.id = Int16(count + 1)
        } else{
            self.id = 1
        }
        self.iItemToBin = CoreDataManager.shared.fetechRequest(entityName: CoreDataModelName.BinModel.rawValue, predicate: NSPredicate(format: "id == %d", itemDic["binId"] as! Int16),context: context)?.first as! BinModel
    }

}
