//
//  ForecastDay.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class ForecastDay: BaseResponse {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    private enum Keys: String {

        case icon_url           = "icon_url"
        case weekday            = "weekday"

        // sub-keys
        case date               = "date"
    }
    
    private enum KeysHigh: String {

        case fahrenheit         = "fahrenheit"
        case celsius            = "celsius"

        // sub-key
        case high               = "high"
    }
    
    private enum KeysLow: String {

        case fahrenheit         = "fahrenheit"
        case celsius            = "celsius"

        // sub-key
        case low                = "low"
    }
    
    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var icon_url: String {

        return getStringByKey(Keys.icon_url.rawValue)
    }
    
    var weekday: String {

        let attributtes = getDictByKey(Keys.date.rawValue)
        let br = BaseResponse(attributes: attributtes)
        return br.getStringByKey(Keys.weekday.rawValue)
    }

    var highF: String {

        let attributes = getDictByKey(KeysHigh.high.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysHigh.fahrenheit.rawValue)
    }
    
    var highC: String {

        let attributes = getDictByKey(KeysHigh.high.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysHigh.celsius.rawValue)
    }

    var lowF: String {

        let attributes = getDictByKey(KeysLow.low.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysLow.fahrenheit.rawValue)
    }
    
    var lowC: String {

        let attributes = getDictByKey(KeysLow.low.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysLow.celsius.rawValue)
    }
    
    ///////////////////////////////////////////////////////////
    // CustomDebugStringConvertible
    ///////////////////////////////////////////////////////////

    override var debugDescription: String {

        // use debug for computed properties
        let base = super.debugDescription
        var computedProps = "Class: \(type(of: self))\n"

        computedProps += "> \(Keys.icon_url.rawValue) = \(icon_url)\n"
        computedProps += "> \(Keys.date.rawValue).\(Keys.weekday.rawValue) = \(weekday)\n"
        computedProps += "> \(KeysHigh.high.rawValue).\(KeysHigh.fahrenheit.rawValue) = \(highF)\n"
        computedProps += "> \(KeysHigh.high.rawValue).\(KeysHigh.celsius.rawValue) = \(highC)\n"
        computedProps += "> \(KeysLow.low.rawValue).\(KeysLow.fahrenheit.rawValue) = \(highC)\n"
        computedProps += "> \(KeysLow.low.rawValue).\(KeysLow.celsius.rawValue) = \(lowC)\n"
        
        return base + computedProps
    }
}
