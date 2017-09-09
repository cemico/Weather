//
//  Weather.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class Weather: BaseResponse {

    ///////////////////////////////////////////////////////////
    // enums
    ///////////////////////////////////////////////////////////

    private enum Keys: String {

        case currentObservation     = "current_observation"
        case location               = "location"
        case hourForecast           = "hourly_forecast"
        case dayForecast            = "forecastday"
        case moonPhase              = "moon_phase"
        case fcttext                = "fcttext"

        // sub-keys
        case forecast               = "forecast"
        case txt_forecast           = "txt_forecast"
        case simpleforecast         = "simpleforecast"
    }

    ///////////////////////////////////////////////////////////
    // properties
    ///////////////////////////////////////////////////////////

    var currentObservation: CurrentObservation {

        let attributes = getDictByKey(Keys.currentObservation.rawValue)
        return CurrentObservation(attributes: attributes)
    }

    var location: Location {

        let attributes = getDictByKey(Keys.location.rawValue)
        return Location(attributes: attributes)
    }

    var hourForecast: [ForecastHour] {

        // get raw values
        let aData = getArrayByKey(Keys.hourForecast.rawValue)

        // convert array
        var aConverted: [ForecastHour] = []
        for data in aData {

            aConverted.append(ForecastHour(attributes: data))
        }

        return aConverted
    }

    var dayForecast: [ForecastDay] {

        // burried down there: forecast/simpleforecast/forecastday
        let forecastDict = getDictByKey(Keys.forecast.rawValue)
        let brForecast = BaseResponse(attributes: forecastDict)
        let simpleForecastDict = brForecast.getDictByKey(Keys.simpleforecast.rawValue)
        let brSimpleForecast = BaseResponse(attributes: simpleForecastDict)

        // get raw values
        let aData = brSimpleForecast.getArrayByKey(Keys.dayForecast.rawValue)

        // convert array
        var aConverted: [ForecastDay] = []
        for data in aData {

            aConverted.append(ForecastDay(attributes: data))
        }

        return aConverted
    }

    var moonPhase: MoonPhase {

        let attributes = getDictByKey(Keys.moonPhase.rawValue)
        return MoonPhase(attributes: attributes)
    }

    var daySummary: String {

        // pull the two text forecasts out for today, i.e. first 2, under forecast/txt_forecast_forecastday[0...1].fcttext
        let forecastDict = getDictByKey(Keys.forecast.rawValue)
        let brForecast = BaseResponse(attributes: forecastDict)
        let txtForecastDict = brForecast.getDictByKey(Keys.txt_forecast.rawValue)
        let brTxtForecast = BaseResponse(attributes: txtForecastDict)

        // get raw values
        let aData = brTxtForecast.getArrayByKey(Keys.dayForecast.rawValue)

        // convert array
        var dayText = ""

        if aData.count >= 0, let data = aData.first {

            let br = BaseResponse(attributes: data)
            let dayForecast = br.getStringByKey(Keys.fcttext.rawValue)
            dayText = "Today: " + dayForecast
        }

        if aData.count >= 1 {

            let data = aData[1]
            let br = BaseResponse(attributes: data)
            let dayForecast = br.getStringByKey(Keys.fcttext.rawValue)
            dayText += "  \(dayForecast)"
        }

        return dayText
    }

    ///////////////////////////////////////////////////////////
    // CustomDebugStringConvertible
    ///////////////////////////////////////////////////////////

    override var debugDescription: String {

        // use debug for computed properties
        let base = super.debugDescription
        var computedProps = "Class: \(type(of: self))\n"

        computedProps += "> \(Keys.currentObservation.rawValue) = \(currentObservation)\n"
        computedProps += "> \(Keys.location.rawValue) = \(location)\n"
        computedProps += "> \(Keys.hourForecast.rawValue) = \(hourForecast)\n"
        computedProps += "> \(Keys.moonPhase.rawValue) = \(moonPhase)\n"

        return base + computedProps
    }
}
