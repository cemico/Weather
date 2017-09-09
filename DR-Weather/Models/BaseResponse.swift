//
//  BaseResponse.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

class BaseResponse: CustomStringConvertible, CustomDebugStringConvertible {

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // note: chose storage as raw dictionary, and setup all access to not crash if keys are not
    //       found, as this is a third party api, trying to keep app from crashing if things change
    //       in the future.  one nice upgrade would be to conditionalize DEBUG to crash if not found
    //       otherwise default value returned
    //
    
    private var _attributes: DaveAttributes = [:]

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var attributes: DaveAttributes {

        get {

            return _attributes
        }

        set {

            _attributes = newValue
        }
    }

    ///////////////////////////////////////////////////////////
    // CustomDebugStringConvertible
    ///////////////////////////////////////////////////////////

    var debugDescription: String {

        // use debug for computed properties
        let computedProps = "Class: BaseResponse\n"
        return computedProps
    }

    ///////////////////////////////////////////////////////////
    // inits
    ///////////////////////////////////////////////////////////

    init(attributes: DaveAttributes) {

        // common init
        initAll(attributes)
    }


    func initAll(_ attributes: DaveAttributes) {

        // save json input
        _attributes = attributes
    }
    
    ///////////////////////////////////////////////////////////
    // helpers to access data in particular ways
    ///////////////////////////////////////////////////////////

    func getAttributeByKey(_ key: String) -> Any? {

        // sanity checks
        guard key.length > 0 else {

            // invalid key
            assertionFailure("Keys should never be empty")
            return nil
        }

        // extract value
        guard let value = attributes[key] else { return nil }

        return value
    }

    func getStringByKey(_ key: String, defaultValue: String = "") -> String {

        // look for key and type
        if let value = getAttributeByKey(key) as? String {

            return value
        }

        // default
        return defaultValue
    }

    func getBoolByKey(_ key: String, defaultValue: Bool = false) -> Bool {

        // look for key and type
        if let value = getAttributeByKey(key) as? NSNumber {

            return value.boolValue
        }

        // default
        return defaultValue
    }

    func getIntByKey(_ key: String, defaultValue: Int = 0) -> Int {

        // look for key and type
        if let value = getAttributeByKey(key) as? Int {

            return value
        }

        // default
        return defaultValue
    }

    func getDoubleByKey(_ key: String, defaultValue: Double = 0) -> Double {

        // look for key and type
        if let value = getAttributeByKey(key) as? Double {

            return value
        }

        // default
        return defaultValue
    }

    func getDictByKey(_ key: String, defaultValue: DaveAttributes = [:]) -> DaveAttributes {

        // look for key and type
        if let value = getAttributeByKey(key) as? DaveAttributes {

            return value
        }

        // default
        return defaultValue
    }

    func getArrayByKey(_ key: String, defaultValue: [DaveAttributes] = []) -> [DaveAttributes] {
        
        // look for key and type
        if let value = getAttributeByKey(key) as? [DaveAttributes] {
            
            return value
        }
        
        // default
        return defaultValue
    }
}
