//
//  BaseResponseTests.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/13/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import XCTest
@testable import DR_Weather

class BaseResponseTests: XCTestCase {

    var baseResponse: BaseResponse!

    struct Constants {

        struct Keys {

            static let stringAttr       = "stringAttr"
            static let boolAttr         = "boolAttr"
            static let intAttr          = "intAttr"
            static let doubleAttr       = "doubleAttr"
            static let dictAttr         = "dictAttr"
            static let arrayAttr        = "arrayAttr"

            static let badKey           = "badKey"
        }

        struct Values {

            static let stringDefault    = "default"
            static let boolDefault      = true
            static let intDefault       = 25
            static let doubleDefault    = Double(25)
            static let dictDefault      = [ "hi" : "mom" ]
            static let arrayDefault     = [ "hi", "mom" ]

            // no badKey entry
        }
    }

    // test data
    let attributes: DaveAttributes = [

        // basic data type tests
        Constants.Keys.stringAttr   : "testString",
        Constants.Keys.boolAttr     : true,
        Constants.Keys.intAttr      : 357,
        Constants.Keys.doubleAttr   : Double(3.57),
        Constants.Keys.dictAttr     : [ "oneString" : "1", "twoInt" : 2 ],
        Constants.Keys.arrayAttr    : [ 1, 2, 3, "one", "two", "three" ]
    ]

    override func setUp() {
        super.setUp()

        // init test objects here (since we used forced unwrap to avoid initializers)
        baseResponse = BaseResponse(attributes: attributes)
    }
    
    override func tearDown() {
        super.tearDown()

        // clear
        baseResponse = nil
    }

    //
    // String tests
    //

    func testStringInvalidKey() {

        // bad key
        let testValue = baseResponse.getStringByKey(Constants.Keys.badKey)
        let expectedValue = ""

        // returns default of empty string
        XCTAssertTrue(testValue == expectedValue)
    }

    func testStringValidKey() {

        // good key
        let key = Constants.Keys.stringAttr
        let testValue = baseResponse.getStringByKey(key)

        // values should be equal
        if let expectedValue = attributes[key] as? String {

            XCTAssertTrue(testValue == expectedValue)
        }
        else {

            XCTFail("Expected String type not returned")
        }
    }

    func testStringDefaultWithEmpty() {

        // bad key with custom default value
        let key = Constants.Keys.badKey
        let defaultValue = ""
        let testValue = baseResponse.getStringByKey(key, defaultValue: defaultValue)
        let expectedValue = defaultValue

        // bad key should return "" unless default passed in, which bad key was resuled as default
        XCTAssertTrue(testValue == expectedValue)
    }
    
    func testStringDefaultWithNonEmpty() {

        // bad key with custom default value
        let key = Constants.Keys.badKey
        let defaultValue = key
        let testValue = baseResponse.getStringByKey(key, defaultValue: defaultValue)
        let expectedValue = defaultValue

        // bad key should return "" unless default passed in, which bad key was resuled as default
        XCTAssertTrue(testValue == expectedValue)
    }
    
    //
    // Bool tests
    //

    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}
