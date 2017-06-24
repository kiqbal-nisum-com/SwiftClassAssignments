//: Playground - noun: a place where people can play

import UIKit

enum EntityType : String {
    case ItemType = "Item"
    case BinType = "Bin"
    case LocationType = "Location"

}

protocol EntityProtocol :class{

    var entityType : EntityType? {get set}
    func printEntityType()
}

class Item : EntityProtocol{
    var entityType: EntityType? {get { return.ItemType} set(value){ self.entityType = value}}
    func printEntityType(){
    
        print(self.entityType)
    }

}

var item = Item()
item.entityType  = EntityType(rawValue: "Bin")
item.printEntityType()
