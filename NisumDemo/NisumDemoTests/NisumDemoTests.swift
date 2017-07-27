//
//  NisumDemoTests.swift
//  NisumDemoTests
//
//  Created by Khurram Iqbal on 24/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import XCTest
@testable import NisumDemo
class NisumDemoTests: XCTestCase {
    
    let vc = ViewController()
    var currencyVal = [String : String]()
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTotalValue(){
        currencyVal["NICKELS"] = "10" // 2 * 10 = 20
        currencyVal["DIMES"] = "4" // 5 * 4 = 20
        recalculateValue()
        XCTAssert(vc.totalValue == 40.0) // total value should be 40

        currencyVal["DIMES"] = "4"
        currencyVal["NICKELS"] = "5"
        currencyVal["$10"] = "10"
        // totalValue should be 130
        recalculateValue()
        XCTAssert(vc.totalValue == 130.0)
        
        currencyVal["50c"] = "10" // 0.5 * 10
        currencyVal.removeValue(forKey: "DIMES") // should not calculate Dimes any more
        recalculateValue() // totalValue should be 115
        XCTAssert(vc.totalValue == 115.0)
        
        currencyVal.removeValue(forKey: "DIMES")
        currencyVal.removeValue(forKey: "$10")
        currencyVal.removeValue(forKey: "NICKELS")
        currencyVal.removeValue(forKey: "50c")
        recalculateValue()
        XCTAssert(vc.totalValue == 0)
    
    }
    
    func setSelectedTexfieldView(index : Int){
            vc.selectedTextfieldView = vc.customTextFieldViews[index]
    }
    
    func recalculateValue(){
        vc.totalValue = 0
        for item in currencyVal{
            vc.totalDenominationValue(labelText: item.key, textValue: item.value)
        }
    }
    
    
    
    
}
