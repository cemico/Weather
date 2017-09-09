//
//  WeatherDataController.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class WeatherDataController {

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // setup singleton
    static let sharedInstance = WeatherDataController()

    // cached data - top level model object
    var weather: Weather?

    // cache direct children - not used in demo, but api was written
    // to allow an update of a specific child directly, for instance
    // the 10 day forecast might not change much over a short timeframe,
    // you could pull everything once, then update the current values only
    var currentObservation: CurrentObservation?
    var forecastDays: [ForecastDay]?
    var forecastHours: [ForecastHour]?
    var location: Location?
    var moonPhase: MoonPhase?
    var daySummary = "Enjoy your day"

    enum HourAggregateType {

        case now, sunrise, sunset, `default`
    }

    // tuple return types
    typealias NowAggregate = (hour: String, minute: String, tempF: String, tempC: String)
    typealias HourAggregate = (type: HourAggregateType, time: String, iconUrl: String, tempOrLabel: String)
    typealias DayAggregate = (day: String, iconUrl: String, hiTemp: String, loTemp: String)
    typealias ConditionAggregate = (key: String, value: String)

    ///////////////////////////////////////////////////////////
    // lifecycle
    ///////////////////////////////////////////////////////////

    private init() {

        print("WeatherDataController Init")
    }

    func clear() {

        NSLock().synchronized { [unowned self] in

            // clear cache
            self.weather = nil
            self.currentObservation = nil
            self.forecastDays = nil
            self.forecastHours = nil
            self.location = nil
            self.moonPhase = nil
            self.daySummary = ""
        }
    }

    ///////////////////////////////////////////////////////////
    // api
    ///////////////////////////////////////////////////////////

    func getWeather(with options: [Router.WeatherPathOptions] = Router.WeatherPathOptions.allOptions, completion: ((Bool) -> Void)? = nil) {

        // fetch on background queue
        DispatchQueue.global(qos: .background).async {

            // no options returns all
            var weatherOptions = options
            if weatherOptions.isEmpty {

                weatherOptions = Router.WeatherPathOptions.allOptions
            }

            // get current geo-location
            let coord = AppDataController.sharedInstance.currentLocation
            Alamofire.request(Router.getGeoLocationWeather(coord, weatherOptions)).responseJSON { [unowned self] response in

                if response.result.isSuccess {

                    print("successfully received data for \(weatherOptions)")
                    if let attributes = response.result.value as? DaveAttributes {

                        // save results in our cache
                        let weather = Weather(attributes: attributes)
                        self.weather = weather
//                        print(weather)

                        // save each component 
                        for weatherOption in weatherOptions {

                            switch weatherOption {

                                case .hourly:
                                    self.forecastHours = weather.hourForecast

                                case .forecast10day:
                                    self.forecastDays = weather.dayForecast
                                    self.daySummary = weather.daySummary

                                case .astronomy:
                                    self.moonPhase = weather.moonPhase

                                case .conditions:
                                    self.currentObservation = weather.currentObservation

                                case .geolookup:
                                    self.location = weather.location
                            }
                        }

                        // message is broadcast on the current queue - use main as this will prompt UI updates
                        DispatchQueue.main.async {

                            // notify listeners that new data has arrived
                            let options = [ Notification.Name.Keys.featureEnums : weatherOptions ]
                            NotificationCenter.default.post(name: .drWeatherUpdated, object: weather, userInfo: options)

                            // inform caller
                            completion?(true)
                        }
                    }
                }
                else {
                    
                    print("Unable to load weather data\n\(response.description)")

                    if let callback = completion {

                        DispatchQueue.main.async {

                            // inform caller
                            callback(false)
                        }
                    }
                }
            }
        }
    }

    func getNow() -> NowAggregate? {

        guard let co = currentObservation else { return nil }
        guard let mp = moonPhase else { return nil }

        let hour = mp.currentHour
        let minute = mp.currentMinute
        let tempF = co.tempF
        let tempC = co.tempC

        return (hour: hour, minute: minute, tempF: tempF, tempC: tempC)
    }

    func getHourlyAggregate() -> [HourAggregate] {

        guard let now = getNow() else { return [] }
        guard let co = currentObservation else { return [] }
        guard let mp = moonPhase else { return [] }
        guard let hourlyForecast = forecastHours, hourlyForecast.count > 0 else { return [] }

        var hours: [HourAggregate] = []

        // now should be first thing, see if it overlaps with the first forecast hour boundary
        let firstHour = hourlyForecast[0]
        if now.hour != firstHour.hour || now.minute != "00" {

            // include now
            let nowHour = HourAggregate(type: .now, time: "Now", iconUrl: co.iconURL, tempOrLabel: co.tempF)
            hours.append(nowHour)
        }

        // find sunrise / sunset index
        var sunriseIndex = -1
        var sunsetIndex = -1
        var addSunsetToEnd = false

        // two cases, sunrise is after the first hour, which is straightforward, like 2 as first and 6 as sunrise,
        // just need to bump up to sunrise.  but, if sunrise is before the first index, like 6am sunrise compared to 
        // first time of 15, then spin foreward until current is now less than, i.e. wrap back around to first hour,
        // then continue search.  once sunrise found, continue and find sunset.

        if let sunriseHour = Int(mp.sunriseHour),
            let sunsetHour = Int(mp.sunsetHour),
            let firstItem = hourlyForecast.first,
            let firstHour = Int(firstItem.hour) {

            var needToSkipToNextDay = firstHour > sunriseHour
            for (index, fcHour) in hourlyForecast.enumerated() {

                if let hour = Int(fcHour.hour) {

                    if needToSkipToNextDay && hour > sunriseHour {

                        // skip to end of day
                        continue
                    }

                    // no longer need to skip
                    needToSkipToNextDay = false

                    if sunriseIndex < 0 {

                        // still looking for first index
                        if hour > sunriseHour {

                            // found sunrise index, now look for sunset since sequentially stored
                            sunriseIndex = index
                        }
                    }
                    else {

                        // looking for last index
                        if hour > sunsetHour {

                            // found sunset index
                            sunsetIndex = index
                            break
                        }
                    }
                }
            }

            // sanity check for add to end
            if sunriseIndex >= 0 && sunsetIndex < 0 {

                addSunsetToEnd = true
            }
        }

        // get hourly forecast
        var fcHours: [HourAggregate] = hourlyForecast.map { forecast in

            let timeInt = Int(forecast.hour)
            let timeNum = (timeInt ?? 0) != 0 ? timeInt! : 24
            let time = (timeNum > 12 ? "\(timeNum - 12)\(forecast.ampm)" : "\(forecast.hour)\(forecast.ampm)")
            return HourAggregate(type: .default, time: time, iconUrl: forecast.icon_url, tempOrLabel: forecast.tempF)
        }

        // inject sunrise and sunset
        if sunsetIndex >= 0 || addSunsetToEnd  {

            // sunset: later in the array, so as to not mess up indexes
            let sunset = mp.sunset
            let sunsetIcon = "nt_sunny.gif"
            let sunsetAgg = HourAggregate(type: .sunset, time: sunset, iconUrl: sunsetIcon, tempOrLabel: "Sunset")

            if addSunsetToEnd {

                fcHours.append(sunsetAgg)
            }
            else {

                fcHours.insert(sunsetAgg, at: sunsetIndex)
            }
        }

        if sunriseIndex >= 0{

            // sunrise: earlier in the array
            let sunrise = mp.sunrise
            let sunriseIcon = "sunny.gif"
            let sunriseAgg = HourAggregate(type: .sunrise, time: sunrise, iconUrl: sunriseIcon, tempOrLabel: "Sunrise")
            fcHours.insert(sunriseAgg, at: sunriseIndex)
        }

        hours.append(contentsOf: fcHours)
        return hours
    }

    func getDailyAggregate() -> [DayAggregate] {

        func extremeRangeBoundsTemp(temp: String) -> String {

            let minimum = -100
            let maximum = 150

            var output = temp
            if let outputI = Int(output) {

                if outputI < minimum || outputI > maximum {

                    output = "?"
                }
            }
            
            return output
        }
        
        guard let dailyForecast = forecastDays, dailyForecast.count > 0 else { return [] }

        var fcDays: [DayAggregate] = dailyForecast.map { forecast in

            // semi-validation
            let lo = extremeRangeBoundsTemp(temp: forecast.lowF)
            let hi = extremeRangeBoundsTemp(temp: forecast.highF)

            return DayAggregate(day: forecast.weekday, iconUrl: forecast.icon_url, hiTemp: hi, loTemp: lo)
        }

        // drop today from 10-day forecast
        if fcDays.count >= 10 {

            fcDays = Array<DayAggregate>(fcDays[1 ... 9])
        }
        
        return fcDays
    }

    func getConditionsAggregate() -> [ConditionAggregate] {

        guard let mp = moonPhase else { return [] }
        guard let co = currentObservation else { return [] }

        var conditions: [ConditionAggregate] = []
        conditions.append(ConditionAggregate(key: "Sunrise", value: mp.sunrise))
        conditions.append(ConditionAggregate(key: "Sunset", value: mp.sunset))

        conditions.append(ConditionAggregate(key: "Chance of Rain", value: "0%"))        // todo
        conditions.append(ConditionAggregate(key: "Humidity", value: co.humidity))

        conditions.append(ConditionAggregate(key: "Wind", value: co.windDirection + " " + co.windMPH + " mph"))
        conditions.append(ConditionAggregate(key: "Feels Like", value: co.feelslikeF + String.degreeSymbol))

        conditions.append(ConditionAggregate(key: "Precipation", value: co.precipitationTodayIN + " in"))
        conditions.append(ConditionAggregate(key: "Pressure", value: co.pressureInHG + " inHg"))

        conditions.append(ConditionAggregate(key: "Visibility", value: co.visibilityMI + " mi"))
        conditions.append(ConditionAggregate(key: "UV Index", value: co.uvIndex))

        return conditions
    }

//    typealias CompareHourMinute = (hour: String, minute: String)
//    private func compareHourMinute(first: CompareHourMinute, second: CompareHourMinute) -> ComparisonResult {
//
//        let firstHour = Int(first.hour)
//        let firstMinute = Int(first.minute)
//        let secondHour = Int(second.hour)
//        let secondMinute = Int(second.minute)
//
//        if firstHour == secondHour && firstMinute == secondMinute {
//
//            return .orderedSame
//        }
//        else if
//    }
}
