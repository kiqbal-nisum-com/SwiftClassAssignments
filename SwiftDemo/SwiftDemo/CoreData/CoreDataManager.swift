//
//  CoreDataManager.swift
//  Music Download
//
//  Created by Khurram Iqbal on 26/05/2017.
//  Copyright © 2017 Khurram Iqbal. All rights reserved.
//

import UIKit
import CoreData

import Foundation
import CoreData
#if os(macOS)
    import AppKit
#endif


enum CoreDataModelName : String{
    case BinModel = "BinModel"
    case ItemModel = "ItemModel"
    case LocationModel = "LocationModel"
    case EntityBaseModel = "EntityBaseModel"
}
public final class CoreDataManager {
    public static let shared = CoreDataManager()                         //singleton instance
    
    /// The name of the bundle where the model data scheme resides
    public static var bundleName = "com.test.*.SwiftDemo"
    /// The filename of the managed object model resource file
    public static var modelObjectName = "SwiftDemo"
    /// The path to append to the directory the application uses to store the Core Data store file
    public static var persistentCoordinatorPath = ""
    
    var errorHandler: (Error) -> Void = {_ in }
    
    //MARK: - all OS stack
    
    public lazy var viewContext: NSManagedObjectContext = {
        if #available(iOS 10.0, OSX 10.12, *) {
            return self.persistentContainer.viewContext
        } else {
            let coordinator = self.persistentStoreCoordinator
            var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        }
    }()
    
    public lazy var backgroundContext: NSManagedObjectContext = {
        if #available(iOS 10.0, OSX 10.12, *) {
            return self.persistentContainer.newBackgroundContext()
        } else {
            let coordinator = self.persistentStoreCoordinator
            var context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        }
    }()
    
    public func saveViewContext() {
        save(context: self.viewContext)
    }
    
    public func saveBackgroundContext() {
        save(context: backgroundContext)
    }
    
    func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print ("------ Model Saved ------")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - iOS 10.0+ && macOS 10.12+ Stack
    
    @available(iOS 10.0, OSX 10.12, *)
    public lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
                let container = NSPersistentContainer(name: modelObjectName)
//        let container = NSPersistentContainer(name: CoreDataManager.modelObjectName, managedObjectModel: self.managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: - macOS 10.10+ && iOS 8.0+ stack
    
    @available(iOS 8.0, OSX 10.10, *)
    private init() {
        //#1
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mainContextChanged(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.viewContext)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bgContextChanged(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: self.backgroundContext)
    }
    
    @available(iOS 8.0, OSX 10.10, *)
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    #if os(iOS)
    @available(iOS 8.0, *)
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:
            self.managedObjectModel)
        let url = self.libraryDirectory.appendingPathComponent("\(CoreDataManager.modelObjectName).sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: url,
                                               options: [
                                                NSMigratePersistentStoresAutomaticallyOption: true,
                                                NSInferMappingModelAutomaticallyOption: true
                ]
            )
        } catch {
            // Report any error we got.
            NSLog("CoreData error \(error)")
            self.errorHandler(error)
        }
        return coordinator
    }()
    #endif
    
    #if os(macOS)
    @available(OSX 10.10, *)
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    let fileManager = FileManager.default
    var failError: NSError? = nil
    var shouldFail = false
    var failureReason = "There was an error creating or loading the application's saved data."
    
    // Make sure the application files directory is there
    do {
    let properties = try self.applicationDocumentsDirectory.resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
    if !properties.isDirectory! {
    failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
    shouldFail = true
    }
    } catch  {
    let nserror = error as NSError
    if nserror.code == NSFileReadNoSuchFileError {
    do {
    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
    } catch {
    failError = nserror
    }
    } else {
    failError = nserror
    }
    }
    
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = nil
    if failError == nil {
    coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("\(CoreDataStack.modelObjectName).storedata")
    do {
    try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
    // Replace this implementation with code to handle the error appropriately.
    
    /*
     Typical reasons for an error here include:
     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
     * The device is out of space.
     * The store could not be migrated to the current model version.
     Check the error message to determine what the actual problem was.
     */
    failError = error as NSError
    }
    }
    
    if shouldFail || (failError != nil) {
    // Report any error we got.
    if let error = failError {
    NSApplication.shared().presentError(error)
    fatalError("Unresolved error: \(error), \(error.userInfo)")
    }
    fatalError("Unsresolved error: \(failureReason)")
    } else {
    return coordinator!
    }
    }()
    #endif
    
    @available(iOS 8.0, OSX 10.10, *)
    public lazy var managedObjectModel: NSManagedObjectModel = {
        guard let bundle = Bundle(identifier: CoreDataManager.bundleName),
            let modelURL = bundle.url(forResource: CoreDataManager.modelObjectName, withExtension: "momd") else { fatalError("Could not instantiate the managed object model.") }
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    @available(iOS 8.0, OSX 10.10, *)
    @objc func mainContextChanged(notification: NSNotification) {
        backgroundContext.perform { [unowned self] in
            self.backgroundContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    
    @available(iOS 8.0, OSX 10.10, *)
    @objc func bgContextChanged(notification: NSNotification) {
        viewContext.perform{ [unowned self] in
            self.viewContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    
    //MARK: - iOS 8.0+ exclusive stack
    
    @available(iOS 8.0, *)
    public lazy var libraryDirectory: URL = {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls.first! as URL
    }()
    
    //MARK: - macOS 10.10+ exclusive stack
    
    @available(OSX 10.10, *)
    public lazy var applicationDocumentsDirectory: Foundation.URL = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent(CoreDataManager.persistentCoordinatorPath)
    }()
    
    func fetechRequest(entityName: String! , predicate :NSPredicate?,context : NSManagedObjectContext)-> [NSManagedObject]?{
        
            
            let fetechRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: entityName)
            if let _ = predicate{
                fetechRequest.predicate = predicate
            }
            do {
                let results = try context.fetch(fetechRequest)
                if results.count == 0 {
                    return nil
                }
                return results
            }
            catch
            {
                print("Error with request: \(error)")
                return nil
            }
            
        }
    
    func saveManageObject( managedObject : NSManagedObject!,context: NSManagedObjectContext){
        
            context.insert(managedObject)
            self.save(context: context)
    }
    
    func deleteManageObject(managedObject : NSManagedObject,context:NSManagedObjectContext){
            context.delete(managedObject)
            self.save(context: context)
        
    }
    func id<U>(object: AnyObject) -> U? {
       
        if let typed = object as? U {
            return typed
        }
        return nil
    }
    
    func newManagedObject (entityName:String, context: NSManagedObjectContext) -> NSManagedObject?{
        
            let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)
            let managedObj =  NSManagedObject(entity: entityDescription!, insertInto: context)
            return managedObj;
        
    }

    
}
