//
//  Router.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

///////////////////////////////////////////////////////////
// alias for ease of reading
///////////////////////////////////////////////////////////

public typealias DaveAttributes = [String: Any]

///////////////////////////////////////////////////////////
// router definition
//
// decent article: https://grokswift.com/router/
//
///////////////////////////////////////////////////////////

enum Router: URLRequestConvertible, URLConvertible {

    //
    // router enums
    //

    // each case can have various arguments if IDs and such need to be passed in
    case getGeoLocationWeather(CLLocationCoordinate2D, [WeatherPathOptions])

    //
    // constants
    //

    private struct Constants {

        struct Api {

            // https://www.wunderground.com/weather/api/d/docs?d=data/index&MR=1
            static let baseURL = "http://api.wunderground.com/api"
        }
    }

    //
    // computed properties
    //

     static var baseURLString: String = {

        // lookup key from info.plist's build-time population from build definitions
        // (which allows different keys for different build targets, say if
        //  you wanted a test key and prod key for debug and release)
        var keyValue = "badApiKey"
        if let value = Bundle.main.stringInfoValue(for: .wundergroundApiKey) {

            keyValue = value
        }
        else {

            print("Check info.plist and user defined build constants for the definition of key: \(Bundle.InfoItemTypes.wundergroundApiKey.rawValue)")
        }

        return "\(Constants.Api.baseURL)/\(keyValue)"
    }()

    var method: Alamofire.HTTPMethod {

        switch self {

            case .getGeoLocationWeather:
                return .get
        }
    }

    var path: String {

        switch self {

            case .getGeoLocationWeather(let coord, let options):

                // for geolocation lookup:
                // format is base/key/[each feature requested followed by slash]/q/lat,lon.json
                var weatherOptions = options
                if weatherOptions.count == 0 {

                    // convience - empty is same as all
                    weatherOptions = WeatherPathOptions.allOptions
                }

                // construct the path of options
                var relativePath = ""
                for option in weatherOptions {

                    if option == .geolookup {

                        // auto added
                        continue
                    }

                    // add each piece to path
                    relativePath += "\(option.rawValue)/"
                }

                // as this routine is the geoLocation routine, finish the options with that path
                relativePath += "\(WeatherPathOptions.geolookup.rawValue)/"

                // next is the query indicator
                relativePath += "q/"

                // finish it off with our geo coords and response format
                relativePath += "\(coord.latitude),\(coord.longitude).json"

                print(relativePath)
                return relativePath
        }
    }

    //
    // filter enum to return only data requested
    //

    enum WeatherPathOptions: String {

        case hourly           = "hourly"              // 36 hourly array immediately following request
        case conditions       = "conditions"          // current values
        case astronomy        = "astronomy"           // sunrise, sunset, etc.
        case forecast10day    = "forecast10day"       // 10 day forecast
        case geolookup        = "geolookup"           // allows input as geolocation

        static var allOptions = [WeatherPathOptions.hourly, .conditions, .astronomy, .forecast10day, .geolookup]
    }

    //
    // error enum
    //

    enum RouterErrors: Error {

        case UnableToCreateURL
    }

    //
    // internal request type enum
    //

    private enum EncodeRequestType {

        case url, json, array, `default`
    }

    //
    // URLConvertible
    //

    func asURL() throws -> URL {

        do {

            // reuse existing framework to get fully composed url
            let urlRequest = try asURLRequest()
            if let url = urlRequest.url {

                return url
            }
        }
        catch let error as NSError {

            print("ERROR \(#function): \(error)")
        }

        // error mapping
        throw RouterErrors.UnableToCreateURL
    }

    //
    // returns a URL request or throws if an `Error` was encountered
    //
    // - throws: An `Error` if the underlying `URLRequest` is `nil`
    //
    // - returns: A URL request
    //

    public func asURLRequest() throws -> URLRequest {

        // setup URL
        guard let URL = Foundation.URL(string: Router.baseURLString) else {

            throw RouterErrors.UnableToCreateURL
        }

        // setup physical request
        var mutableURLRequest = URLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue

        // add any headers if needed
//        mutableURLRequest.setValue(value, forHTTPHeaderField: key)

        // provide any parameter encoding if needed
        switch self {

            // perhaps blocks for each type of EncodeRequestType

//            // json example
//            case .createABC(let parameters):
//                return encodeRequest(mutableURLRequest, requestType: .json, parameters: parameters)
//
//            // url example
//            case .updateABC(let parameters):
//                return encodeRequest(mutableURLRequest, requestType: .url, parameters: parameters)
//
//            // array example (body encoding of array values)
//            case .postABCResponses(let arrayItems):
//                return encodeRequest(mutableURLRequest, requestType: .array, arrayItems: arrayItems)

            // our call is simple, no parameters, use default
//            case .getGeoLocationWeather()
            default:
                return encodeRequest(mutableURLRequest, requestType: .default)
        }
    }

    private func encodeRequest(_ mutableURLRequest: URLRequest,
                               requestType: EncodeRequestType,
                               parameters: DaveAttributes? = nil,
                               arrayItems: [DaveAttributes]? = nil) -> URLRequest {

        var encodedMutableURLRequest = mutableURLRequest

        // encode requested data
        switch requestType {

            case .json:
                encodedMutableURLRequest = try! Alamofire.JSONEncoding.default.encode(mutableURLRequest, with: parameters)

            case .url:
                encodedMutableURLRequest = try! Alamofire.URLEncoding.default.encode(mutableURLRequest, with: parameters)

            case .array:

                if let arrayItems = arrayItems {

                    // encode array to body
                    do {

                        // pass data in body of request
                        let data = try JSONSerialization.data(withJSONObject: arrayItems, options: [])
                        encodedMutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        encodedMutableURLRequest.httpBody = data
                    }
                    catch let error as NSError {

                        print("ERROR Array JSON serialization failed: \(error)")

                    }
                }

            default:
                // no encoding - use passed in mutableURLRequest
                break
        }

        if let url = encodedMutableURLRequest.url {
            
            print("URL: \(url)")
        }
        return encodedMutableURLRequest
    }
}
