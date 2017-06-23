//
//  NetworkOperations.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 23/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class NetworkOperations: NSObject {
   
    public static let sharedInstance = NetworkOperations ()
    let coreDataManager = CoreDataManager.shared
    
    func getAllData (dataType : String!, completionHandler : (_ responseObject : Dictionary<String, Any>? , _ success : Bool)->Void) {
        
        let urlRequest = URLRequest(url: URL(string: AppConstant.baseURL + dataType)!)
        let urlSession = URLSession.shared
        let taskSession = urlSession.dataTask(with: urlRequest, completionHandler : {[unowned self] (data, response, error) -> Void in
            
            let jsonRespone = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            self.insertDataToCoreData(dict: jsonRespone as! [String : Any])
            
        })
        
        taskSession.resume()
     
    }
    
    func insertDataToCoreData(dict : [String : Any]){
        print (dict)
        let context = CoreDataManager.shared.backgroundContext
        for loc  in dict["location"] as! NSArray{
            let locModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.LocationModel.rawValue,context: context) as! LocationModel
            locModel.setLocation(locDict: loc as! [String : Any], context: context)
        }
        CoreDataManager.shared.saveBackgroundContext()
        for bin  in dict["bin"] as! NSArray{
           let binModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.BinModel.rawValue,context: context) as! BinModel
            binModel.setBin(binDict: bin as! [String : Any],context: context)
        }
        CoreDataManager.shared.saveBackgroundContext()

        for item in dict["item"] as! NSArray{
            let itemModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.ItemModel.rawValue,context: context) as! ItemModel
            itemModel.setItem(itemDic: item as! [String : Any],context: context)
        
        }
        CoreDataManager.shared.saveBackgroundContext()

    
    }

}
