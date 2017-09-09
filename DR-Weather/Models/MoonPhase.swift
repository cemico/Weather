//
//  MoonPhase.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class MoonPhase: BaseResponse {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    private enum Keys: String {

        case phaseOfMoon        = "phaseofMoon"
    }

    // sub-dict keys, repeating values so in own enums
    private enum KeysCurrentTime: String {

        case hour               = "hour"
        case minute             = "minute"

        // sub-dict keys
        case currentTime        = "current_time"
    }
    
    private enum KeysSunrise: String {

        case hour               = "hour"
        case minute             = "minute"

        // sub-dict keys
        case sunrise            = "sunrise"
    }
    
    private enum KeysSunset: String {

        case hour               = "hour"
        case minute             = "minute"

        // sub-dict keys
        case sunset             = "sunset"
    }
    
    private enum KeysMoonrise: String {

        case hour               = "hour"
        case minute             = "minute"

        // sub-dict keys
        case moonrise           = "moonrise"
    }
    
    private enum KeysMoonset: String {

        case hour               = "hour"
        case minute             = "minute"

        // sub-dict keys
        case moonset            = "moonset"
    }
    
    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var phaseOfMoon: String {

        return getStringByKey(Keys.phaseOfMoon.rawValue)
    }

    var currentHour: String {

        let attributes = getDictByKey(KeysCurrentTime.currentTime.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysCurrentTime.hour.rawValue)
    }
    
    var currentMinute: String {

        let attributes = getDictByKey(KeysCurrentTime.currentTime.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysCurrentTime.minute.rawValue)
    }
    
    var sunriseHour: String {

        let attributes = getDictByKey(KeysSunrise.sunrise.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysSunrise.hour.rawValue)
    }

    var sunriseMinute: String {

        let attributes = getDictByKey(KeysSunrise.sunrise.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysSunrise.minute.rawValue)
    }

    var sunsetHour: String {

        let attributes = getDictByKey(KeysSunset.sunset.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysSunset.hour.rawValue)
    }

    var sunsetMinute: String {

        let attributes = getDictByKey(KeysSunset.sunset.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysSunset.minute.rawValue)
    }

    var moonriseHour: String {

        let attributes = getDictByKey(KeysMoonrise.moonrise.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysMoonrise.hour.rawValue)
    }

    var moonriseMinute: String {

        let attributes = getDictByKey(KeysMoonrise.moonrise.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysMoonrise.minute.rawValue)
    }

    var moonsetHour: String {

        let attributes = getDictByKey(KeysMoonset.moonset.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysMoonset.hour.rawValue)
    }

    var  moonsetMinute: String {

        let attributes = getDictByKey(KeysMoonset.moonset.rawValue)
        let br = BaseResponse(attributes: attributes)
        return br.getStringByKey(KeysMoonset.minute.rawValue)
    }

    ///////////////////////////////////////////////////////////
    // helpers
    ///////////////////////////////////////////////////////////

    var sunrise: String {

        return adjust24to12HourClock(hour: sunriseHour, minute: sunriseMinute)
    }

    var sunset: String {

        return adjust24to12HourClock(hour: sunsetHour, minute: sunsetMinute)
    }

    private func adjust24to12HourClock(hour: String, minute: String) -> String {

        if let hour = Int(hour) {

            if hour > 12 {

                // scale back since on 12-hour clock
                return "\(hour - 12):\(minute) PM"
            }
        }

        return "\(hour):\(minute) AM"
    }

    ///////////////////////////////////////////////////////////
    // CustomDebugStringConvertible
    ///////////////////////////////////////////////////////////

    override var debugDescription: String {

        // use debug for computed properties
        let base = super.debugDescription
        var computedProps = "Class: \(type(of: self))\n"

        computedProps += "> \(Keys.phaseOfMoon.rawValue) = \(phaseOfMoon)\n"
        computedProps += "> \(KeysCurrentTime.currentTime.rawValue).\(KeysCurrentTime.hour.rawValue) = \(currentHour)\n"
        computedProps += "> \(KeysCurrentTime.currentTime.rawValue).\(KeysCurrentTime.minute.rawValue) = \(currentMinute)\n"
        computedProps += "> \(KeysSunrise.sunrise.rawValue).\(KeysSunrise.hour.rawValue) = \(sunriseHour)\n"
        computedProps += "> \(KeysSunrise.sunrise.rawValue).\(KeysSunrise.minute.rawValue) = \(sunriseMinute)\n"
        computedProps += "> \(KeysSunset.sunset.rawValue).\(KeysSunset.hour.rawValue) = \(sunsetHour)\n"
        computedProps += "> \(KeysSunset.sunset.rawValue).\(KeysSunset.minute.rawValue) = \(sunsetMinute)\n"
        computedProps += "> \(KeysMoonrise.moonrise.rawValue).\(KeysMoonrise.hour.rawValue) = \(moonriseHour)\n"
        computedProps += "> \(KeysMoonrise.moonrise.rawValue).\(KeysMoonrise.minute.rawValue) = \(moonriseMinute)\n"
        computedProps += "> \(KeysMoonset.moonset.rawValue).\(KeysMoonset.hour.rawValue) = \(moonsetHour)\n"
        computedProps += "> \(KeysMoonset.moonset.rawValue).\(KeysMoonset.minute.rawValue) = \(moonsetMinute)\n"

        return base + computedProps
    }
}
