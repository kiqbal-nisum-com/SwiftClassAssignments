//
//  SwiftDemoTests.swift
//  SwiftDemoTests
//
//  Created by khurram iqbal on 06/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import XCTest
import CoreData
@testable import SwiftDemo
class SwiftDemoTests: XCTestCase {
    
    let coredataManager = CoreDataManager.shared
    let context = CoreDataManager.shared.viewContext
    let backgroundContext = CoreDataManager.shared.backgroundContext
    override func setUp() {
        super.setUp()
        continueAfterFailure = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func coreDataBackgroundLoad()   {
        let backgroundDataCoordinatorExpectation = expectation(description: "BackgroundDataCoordinator loads Item in background")
        NetworkOperations.sharedInstance.getAllData(dataType: AppConstant.allData, completionHandler:{ (dataDictionary, success) -> Void in
            XCTAssert(success)
            backgroundDataCoordinatorExpectation.fulfill()
        })
        waitForExpectations(timeout: 1) {
            error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testCoreDataFetchEntityById()  {
        coreDataBackgroundLoad()
        //Test happy path:
        var item:ItemModel? = coredataManager.fetechRequestElement(entityName: CoreDataModelName.ItemModel.rawValue, predicate: NSPredicate(format:"id == %d",1), context: context)
        XCTAssert(item?.name == "item1")
        //Test no object path:
        item = coredataManager.fetechRequestElement(entityName: CoreDataModelName.ItemModel.rawValue, predicate: NSPredicate(format:"name == %@","Final Item"), context: context)
        XCTAssertNil(item)
        // TODO: test error path:
        let entityBase:EntityBaseModel? = coredataManager.fetechRequestElement(entityName: CoreDataModelName.EntityBaseModel.rawValue, predicate:  NSPredicate(format:"name == %@","Final Item"), context: context)
        XCTAssertNil(entityBase)
    }
    
    func testCoreDataFetchEntityByName()  {
        coreDataBackgroundLoad()
        //Test happy path:
        let testName = "item1"
        var item:ItemModel? = coredataManager.fetechRequestElement(entityName: CoreDataModelName.ItemModel.rawValue, predicate: NSPredicate(format : "name == %@",testName), context: context)
        XCTAssert(item?.name == testName)
        //Test no object path:
        item = coredataManager.fetechRequestElement(entityName: CoreDataModelName.ItemModel.rawValue, predicate: NSPredicate(format : "name == %@","abc xyz item"), context: context)
        XCTAssertNil(item)
        // TODO: test error path:
        let entityBase:EntityBaseModel? = coredataManager.fetechRequestElement(entityName: CoreDataModelName.EntityBaseModel.rawValue, predicate: NSPredicate(format : "id == %d",100), context: context)
        XCTAssertNil(entityBase)
    }
    
    func testCoreDataFetchedResultsController() {
        coreDataBackgroundLoad()
        let fetechResultController = coredataManager.fetchedResultsController
        fetechResultController.fetchRequest.predicate = NSPredicate(format : "entityTypeModel == %@",EntityType.Item.rawValue)
        do {
            try fetechResultController.performFetch()
            XCTAssert((fetechResultController.fetchedObjects?.count)! > 0)
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    
}
