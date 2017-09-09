//
//  NotificationName_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Notification.Name {

    struct Keys {

        static let featureEnums     = "features"
        static let locationUpdated  = "locationUpdated"
        static let locationError    = "locationError"
    }

    static let drWeatherUpdated     = Notification.Name("com.cemico.events.weatherUpdated")
    static let drLocationQuery      = Notification.Name("com.cemico.events.locationQuery")
    static let drLocationUpdated    = Notification.Name("com.cemico.events.locationUpdated")
    static let drLocationError      = Notification.Name("com.cemico.events.locationError")
}
