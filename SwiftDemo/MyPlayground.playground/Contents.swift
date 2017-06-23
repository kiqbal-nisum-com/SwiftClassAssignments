//: Playground - noun: a place where people can play

import Foundation
enum EntityType :String  {

    case ItemType = "ItemType"
    case BinType = "BinType"
    case LocationType = "LocationType"
}
    
var entityType  = EntityType(rawValue : "BinType" )

if entityType == .BinType{
    print (true)
}
print(entityType!.rawValue)



