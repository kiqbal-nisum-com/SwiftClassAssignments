//
//  SwiftDemoUITests.swift
//  SwiftDemoUITests
//
//  Created by khurram iqbal on 06/07/2017.
//  Copyright © 2017 Nisum. All rights reserved.
//

import XCTest

class SwiftDemoUITests: XCTestCase {
        
    let app = XCUIApplication()
    
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        print(app.debugDescription)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectLocation()    {
        createLocation(locationName: "New Test Location 1")
        createLocation(locationName: "New Test Location 2")
        selectPickerVal(val:"New Test Location 2",textFieldAccesibleValue:"TextLocation")
    }
    
    func testSelectBin()    {
        selectPickerVal(val:"New Test Location 2",textFieldAccesibleValue:"TextLocation")
        createBin(binName: "New Test Bin 1")
        createBin(binName: "New Test Bin 2")
        selectPickerVal(val:"New Test Bin 2",textFieldAccesibleValue:"TextBin")
    }
    
    func selectPickerVal(val : String, textFieldAccesibleValue : String )   {
        let textField = app.textFields[textFieldAccesibleValue]
        textField.tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: val)
        waitForElementValueToUpdate(element: textField, expectedValue: val)
        XCTAssert(app.textFields[textFieldAccesibleValue].value as! String == val)
    }
    
    func testCreateItem() {
        print(app.debugDescription)
        let itemTextField = app.textFields["TextItem"]
        itemTextField.tap()
        itemTextField.typeText("Test Item 1")
        
        let qtyTextField = app.textFields["TextQuantity"]
        qtyTextField.tap()
        qtyTextField.typeText("13")
        selectPickerVal(val: "New Test Bin 1", textFieldAccesibleValue: "TextBin")
        selectPickerVal(val: "New Test Location 1", textFieldAccesibleValue: "TextLocation")
        app.buttons["Save Button"].tap()
        XCTAssert((itemTextField.value as! String).isEmpty)
    }
    
    func createLocation(locationName:String)    {
        app.buttons["Add Location Button"].tap()
        let alert = app.alerts["Location"]
        let locationTextField = alert.textFields["Location"]
        locationTextField.typeText(locationName)
        alert.buttons["Save"].tap()
        XCTAssert(app.textFields["TextLocation"].value as! String == locationName)
    }
    
    func createBin(binName:String)    {
        
        let locTextField = app.textFields["TextLocation"]
        locTextField.tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: "New Test Location 1")
        
        app.buttons["Add Bin Button"].tap()
        let alert = app.alerts["Bin"]
        let binTextField = alert.textFields["Bin"]
        binTextField.typeText(binName)
        alert.buttons["Save"].tap()
        XCTAssert(app.textFields["TextBin"].value as! String == binName)
    }
    
    func waitForElementToAppear(_ element: XCUIElement) {
        let predicate = NSPredicate(format: "exists == true")
        let _ = expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 1)
    }
    
    func waitForElementToDisappear(_ element: XCUIElement) {
        let predicate = NSPredicate(format: "exists == false")
        let _ = expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 1)
    }
    
    func waitForElementValueToUpdate(element: XCUIElement, expectedValue: String) {
        let predicate = NSPredicate(format: "value == %@", expectedValue)
        let _ = expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 2)
    }
    
}
