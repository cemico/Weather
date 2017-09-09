//
//  CurrentObservation.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import UIKit

class CurrentObservation: BaseResponse {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    private enum Keys: String {

        case lastUpdatedFriendly        = "observation_time"
        case lastUpdatedRcf822          = "local_time_rfc822"
        case weatherCondition           = "weather"
        case tempF                      = "temp_f"
        case tempC                      = "temp_c"
        case humidity                   = "relative_humidity"
        case windFriendly               = "wind_string"
        case windDirection              = "wind_dir"
        case windMPH                    = "wind_mph"
        case windKPH                    = "wind_kph"
        case windGustMPH                = "wind_gust_mph"
        case windGustKPH                = "wind_gust_kph"
        case pressureInHG               = "pressure_in"
        case dewpointF                  = "dewpoint_f"
        case dewpointC                  = "dewpoint_c"
        case feelslikeF                 = "feelslike_f"
        case feelslikeC                 = "feelslike_c"
        case visibilityMI               = "visibility_mi"
        case visibilityKM               = "visibility_km"
        case uvIndex                    = "UV"
        case precipitationTodayIN       = "precip_today_in"
        case precipitationTodayMM       = "precip_today_metric"
        case iconURL                    = "icon_url"
    }

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var lastUpdatedFriendly: String {

        return getStringByKey(Keys.lastUpdatedFriendly.rawValue)
    }

    var lastUpdatedRcf822: String {

        return getStringByKey(Keys.lastUpdatedRcf822.rawValue)
    }

    var weatherCondition: String {

        return getStringByKey(Keys.weatherCondition.rawValue)
    }

    var tempF: String {

        let dValue = getDoubleByKey(Keys.tempF.rawValue)
        return dValue.asString(numDecimals: 0)
    }

    var tempC: String {

        let dValue = getDoubleByKey(Keys.tempC.rawValue)
        return dValue.asString(numDecimals: 0)
    }

    var humidity: String {

        return getStringByKey(Keys.humidity.rawValue)
    }

    var windFriendly: String {

        return getStringByKey(Keys.windFriendly.rawValue)
    }

    var windDirection: String {

        return getStringByKey(Keys.windDirection.rawValue)
    }

    var windMPH: String {

        let dValue = getDoubleByKey(Keys.windMPH.rawValue)
        return dValue.asString(numDecimals: 1)
    }

    var windKPH: String {

        let dValue = getDoubleByKey(Keys.windKPH.rawValue)
        return dValue.asString(numDecimals: 1)
    }

    var windGustMPH: String {

        return getStringByKey(Keys.windGustMPH.rawValue)
    }

    var windGustKPH: String {

        return getStringByKey(Keys.windGustKPH.rawValue)
    }

    var pressureInHG: String {

        return getStringByKey(Keys.pressureInHG.rawValue)
    }

    var dewpointF: String {

        let dValue = getDoubleByKey(Keys.dewpointF.rawValue)
        return dValue.asString(numDecimals: 0)
    }

    var dewpointC: String {

        let dValue = getDoubleByKey(Keys.dewpointC.rawValue)
        return dValue.asString(numDecimals: 0)
    }

    var feelslikeF: String {

        return getStringByKey(Keys.feelslikeF.rawValue)
    }

    var feelslikeC: String {

        return getStringByKey(Keys.feelslikeC.rawValue)
    }

    var visibilityMI: String {

        return getStringByKey(Keys.visibilityMI.rawValue)
    }

    var visibilityKM: String {

        return getStringByKey(Keys.visibilityKM.rawValue)
    }

    var uvIndex: String {

        return getStringByKey(Keys.uvIndex.rawValue)
    }

    var precipitationTodayIN: String {

        return getStringByKey(Keys.precipitationTodayIN.rawValue)
    }

    var precipitationTodayMM: String {
        
        return getStringByKey(Keys.precipitationTodayMM.rawValue)
    }
    
    var iconURL: String {
        
        return getStringByKey(Keys.iconURL.rawValue)
    }

    var icon: UIImage? {

        return iconURL.gifImageFromUrlString()
    }

    ///////////////////////////////////////////////////////////
    // CustomDebugStringConvertible
    ///////////////////////////////////////////////////////////

    override var debugDescription: String {

        // use debug for computed properties
        let base = super.debugDescription
        var computedProps = "Class: \(type(of: self))\n"

        computedProps += "> \(Keys.lastUpdatedFriendly.rawValue) = \(lastUpdatedFriendly)\n"
        computedProps += "> \(Keys.lastUpdatedRcf822.rawValue) = \(lastUpdatedRcf822)\n"
        computedProps += "> \(Keys.weatherCondition.rawValue) = \(weatherCondition)\n"
        computedProps += "> \(Keys.tempF.rawValue) = \(tempF)\n"
        computedProps += "> \(Keys.tempC.rawValue) = \(tempC)\n"
        computedProps += "> \(Keys.humidity.rawValue) = \(humidity)\n"
        computedProps += "> \(Keys.windFriendly.rawValue) = \(windFriendly)\n"
        computedProps += "> \(Keys.windDirection.rawValue) = \(windDirection)\n"
        computedProps += "> \(Keys.windMPH.rawValue) = \(windMPH)\n"
        computedProps += "> \(Keys.windKPH.rawValue) = \(windKPH)\n"
        computedProps += "> \(Keys.windGustMPH.rawValue) = \(windGustMPH)\n"
        computedProps += "> \(Keys.windGustKPH.rawValue) = \(windGustKPH)\n"
        computedProps += "> \(Keys.pressureInHG.rawValue) = \(pressureInHG)\n"
        computedProps += "> \(Keys.dewpointF.rawValue) = \(dewpointF)\n"
        computedProps += "> \(Keys.dewpointC.rawValue) = \(dewpointC)\n"
        computedProps += "> \(Keys.feelslikeF.rawValue) = \(feelslikeF)\n"
        computedProps += "> \(Keys.feelslikeC.rawValue) = \(feelslikeC)\n"
        computedProps += "> \(Keys.visibilityMI.rawValue) = \(visibilityMI)\n"
        computedProps += "> \(Keys.visibilityKM.rawValue) = \(visibilityKM)\n"
        computedProps += "> \(Keys.uvIndex.rawValue) = \(uvIndex)\n"
        computedProps += "> \(Keys.precipitationTodayIN.rawValue) = \(precipitationTodayIN)\n"
        computedProps += "> \(Keys.precipitationTodayMM.rawValue) = \(precipitationTodayMM)\n"
        computedProps += "> \(Keys.lastUpdatedRcf822.rawValue) = \(lastUpdatedRcf822)\n"
        computedProps += "> \(Keys.iconURL.rawValue) = \(iconURL)\n"

        return base + computedProps
    }
}
