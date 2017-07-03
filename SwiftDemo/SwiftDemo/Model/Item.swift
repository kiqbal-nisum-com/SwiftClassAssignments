//
//  Item.swift
//  SwiftDemo
//
//  Created by khurram iqbal on 15/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//



class Item: EntityProtocol {
    
    var name: String?
    var entityType: EntityType {return .Item}
    var bin : Bin?
    var qty : Int = 0
    
    init(itemnName : String?, bin : Bin?,qty : String?){
        self.name = itemnName
        self.bin = bin
       
        if !(qty?.isEmpty)!{
            self.qty = Int(qty!)!
        }
        
    }
     init() {
    }
    
}
