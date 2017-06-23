//
//  NetworkOperations.swift
//  SwiftDemo
//
//  Created by Khurram Iqbal on 23/06/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import UIKit

class NetworkOperations: NSObject {
    
    let sharedInstance = NetworkOperations ()
    let coreDataManager = CoreDataManager.shared
    
    func getAllData (completionHandler : (_ responseObject : Dictionary<String, Any>? , _ success : Bool)->Void){
    
        let urlSession = URLSessionTask()
        let url = URL(string: AppConstant.baseURL + AppConstant.allData)
        
        urlSession.
        
    
    }

}
