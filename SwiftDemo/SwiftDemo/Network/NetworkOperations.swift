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
    
    func getAllData (dataType : String!, completionHandler : @escaping (_ responseObject : Dictionary<String, Any>? , _ success : Bool)->Void) {
        
        let urlRequest = URLRequest(url: URL(string: AppConstant.baseURL + dataType)!)
        let urlSession = URLSession.shared
        let taskSession = urlSession.dataTask(with: urlRequest, completionHandler : {[unowned self] (data, response, error) -> Void in
            
            let jsonRespone = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            self.insertDataToCoreData(dict: jsonRespone as! [String : Any])
            completionHandler(jsonRespone as? [String : Any], true)
            
        })
        
        taskSession.resume()
     
    }
    
    func insertDataToCoreData(dict : [String : Any]){
    
        let context = CoreDataManager.shared.backgroundContext
        for loc  in dict["location"] as! NSArray{
            if self.manageObjectExist(dict: loc as! [String : Any], entityName: CoreDataModelName.LocationModel.rawValue){
                return
            }
            let locModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.LocationModel.rawValue,context: context) as! LocationModel
            locModel.setLocation(locDict: loc as! [String : Any], context: context)
        }
        CoreDataManager.shared.saveBackgroundContext()
        for bin  in dict["bin"] as! NSArray{
            if self.manageObjectExist(dict: bin as! [String : Any], entityName: CoreDataModelName.BinModel.rawValue){
                return
            }
           let binModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.BinModel.rawValue,context: context) as! BinModel
            binModel.setBin(binDict: bin as! [String : Any],context: context)
        }
        CoreDataManager.shared.saveBackgroundContext()

        for item in dict["item"] as! NSArray{
            if self.manageObjectExist(dict: item as! [String : Any], entityName: CoreDataModelName.ItemModel.rawValue){
                return
            }
            let itemModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.ItemModel.rawValue,context: context) as! ItemModel
            itemModel.setItem(itemDic: item as! [String : Any],context: context)
        
        }
        CoreDataManager.shared.saveBackgroundContext()
    }

    func manageObjectExist(dict : [String : Any], entityName : String) -> Bool{
    
        if let _ =   self.coreDataManager.fetechRequest(entityName: entityName, predicate: NSPredicate(format: "id = %d", dict["id"]as! Int16), context: self.coreDataManager.viewContext) {
            return true
        }
        return false
    }
}
