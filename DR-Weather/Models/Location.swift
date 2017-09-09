//
//  Location.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class Location: BaseResponse {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    private enum Keys: String {

        case city           = "city"
        case country        = "country"
        case latitude       = "lat"
        case longitude      = "lon"
        case timezone       = "tz_long"
    }

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var city: String {

        return getStringByKey(Keys.city.rawValue)
    }

    var country: String {

        return getStringByKey(Keys.country.rawValue)
    }

    var latitude: String {

        return getStringByKey(Keys.latitude.rawValue)
    }

    var longitude: String {

        return getStringByKey(Keys.longitude.rawValue)
    }

    var timezone: String {

        return getStringByKey(Keys.timezone.rawValue)
    }

    ///////////////////////////////////////////////////////////
    // CustomDebugStringConvertible
    ///////////////////////////////////////////////////////////

    override var debugDescription: String {

        // use debug for computed properties
        let base = super.debugDescription
        var computedProps = "Class: \(type(of: self))\n"

        computedProps += "> \(Keys.city.rawValue) = \(city)\n"
        computedProps += "> \(Keys.country.rawValue) = \(country)\n"
        computedProps += "> \(Keys.latitude.rawValue) = \(latitude)\n"
        computedProps += "> \(Keys.longitude.rawValue) = \(longitude)\n"
        computedProps += "> \(Keys.timezone.rawValue) = \(timezone)\n"

        return base + computedProps
    }
}
