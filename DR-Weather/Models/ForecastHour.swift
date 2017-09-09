//
//  ForecastHourly.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class ForecastHour: BaseResponse {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    private enum Keys: String {

        case weatherCondition   = "condition"
        case icon_url           = "icon_url"
        case sky                = "sky"

        // FCTTIME
        case hour               = "hour"
        case ampm               = "ampm"

        // temp
        case tempF              = "english"
        case tempC              = "metric"

        // sub-dict keys
        case FCTTIME            = "FCTTIME"
        case temp               = "temp"
    }

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var weatherCondition: String {

        return getStringByKey(Keys.weatherCondition.rawValue)
    }

    var icon_url: String {

        return getStringByKey(Keys.icon_url.rawValue)
    }

    var sky: String {

        return getStringByKey(Keys.sky.rawValue)
    }

    var hour: String {

        let attributes = getDictByKey(Keys.FCTTIME.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(Keys.hour.rawValue)
    }
    
    var ampm: String {

        let attributes = getDictByKey(Keys.FCTTIME.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(Keys.ampm.rawValue)
    }
    
    var tempF: String {

        let attributes = getDictByKey(Keys.temp.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(Keys.tempF.rawValue)
    }
    
    var tempC: String {

        let attributes = getDictByKey(Keys.temp.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(Keys.tempC.rawValue)
    }
    
    ///////////////////////////////////////////////////////////
    // CustomDebugStringConvertible
    ///////////////////////////////////////////////////////////

    override var debugDescription: String {

        // use debug for computed properties
        let base = super.debugDescription
        var computedProps = "Class: \(type(of: self))\n"

        computedProps += "> \(Keys.weatherCondition.rawValue) = \(weatherCondition)\n"
        computedProps += "> \(Keys.icon_url.rawValue) = \(icon_url)\n"
        computedProps += "> \(Keys.sky.rawValue) = \(sky)\n"
        computedProps += "> \(Keys.FCTTIME.rawValue).\(Keys.hour.rawValue) = \(hour)\n"
        computedProps += "> \(Keys.FCTTIME.rawValue).\(Keys.ampm.rawValue) = \(ampm)\n"
        computedProps += "> \(Keys.temp.rawValue).\(Keys.tempF.rawValue) = \(tempF)\n"
        computedProps += "> \(Keys.temp.rawValue).\(Keys.tempC.rawValue) = \(tempC)\n"

        return base + computedProps
    }
}
