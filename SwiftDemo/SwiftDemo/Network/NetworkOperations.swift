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
            

            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode == 200{
                let jsonRespone = try? JSONSerialization.jsonObject(with: data!, options: [])
                self.insertDataToCoreData(dict: jsonRespone as! [String : Any])
                completionHandler(jsonRespone as? [String : Any], true)
            } else {
                completionHandler(nil, false)
            }

        })
        taskSession.resume()
    }
    
    func insertDataToCoreData(dict : [String : Any]){
    
        let context = CoreDataManager.shared.backgroundContext
        for loc  in dict["location"] as! NSArray{
            if !self.manageObjectExist(dict: loc as! [String : Any], entityName: CoreDataModelName.LocationModel.rawValue){
                let locModel : LocationModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.LocationModel.rawValue,context: context)!
                locModel.setObjectProperties(jsonDict: loc as! [String : Any], entityType: EntityType.Location.rawValue, context: context)
            }
         
        }
        CoreDataManager.shared.saveBackgroundContext()
        for bin  in dict["bin"] as! NSArray{
            if !self.manageObjectExist(dict: bin as! [String : Any], entityName: CoreDataModelName.BinModel.rawValue){
                let binModel : BinModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.BinModel.rawValue,context: context)!
                binModel.setObjectProperties(jsonDict: bin as! [String : Any], entityType: EntityType.Bin.rawValue, context: context)
            }
        }
        CoreDataManager.shared.saveBackgroundContext()

        for item in dict["item"] as! NSArray{
            if !self.manageObjectExist(dict: item as! [String : Any], entityName: CoreDataModelName.ItemModel.rawValue){
                let itemModel : ItemModel = self.coreDataManager.newManagedObject(entityName: CoreDataModelName.ItemModel.rawValue,context: context)!
                itemModel.setObjectProperties(jsonDict: item as! [String : Any], entityType: EntityType.Item.rawValue, context: context)
            }
        }
        CoreDataManager.shared.saveBackgroundContext()
    }

    func manageObjectExist(dict : [String : Any], entityName : String) -> Bool{
    

        if let _ : EntityBaseModel =   self.coreDataManager.fetechRequestElement(entityName: entityName, predicate: NSPredicate(format: "id = %d", dict["id"] as! Int16), context: self.coreDataManager.viewContext) {
            return true
        }
        return false
    }
}
