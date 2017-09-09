//
//  AppDataController.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation
import SwiftyGif
import CoreLocation

class AppDataController: NSObject, CLLocationManagerDelegate {

    ///////////////////////////////////////////////////////////
    // constants
    ///////////////////////////////////////////////////////////

    private struct Constants {

        static let swiftyGifMemoryLimit = 40
        static let plumeLatitude        = 37.4276603
        static let plumeLongitude       = -122.14410629999998
    }

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // setup singleton
    static let sharedInstance = AppDataController()

    // cached data
    lazy var gifManager: SwiftyGifManager = {

        // enough to hold all the tiny gif images
        return SwiftyGifManager(memoryLimit: Constants.swiftyGifMemoryLimit)
    }()

    // track location
    private lazy var locationManager: CLLocationManager = {

        let mgr = CLLocationManager()

        // wire ourselves
        mgr.delegate = self

        // be kind to the battery, should be fine for weather conditions
        mgr.desiredAccuracy = kCLLocationAccuracyThreeKilometers

        // another battery conservation item
        mgr.pausesLocationUpdatesAutomatically = true

        // help services determine when to update
        mgr.activityType = .other

        return mgr
    }()

    // used at startup to prevent multiple requests
    private var previousLocationAuthStatus: CLAuthorizationStatus?

    // as Plume as default :)
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Constants.plumeLatitude, Constants.plumeLongitude)

    ///////////////////////////////////////////////////////////
    // lifecycle
    ///////////////////////////////////////////////////////////

    private override init() {

        super.init()
        print("AppDataController Init")

        // listen for app foregrounding and update latest weather
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(notification:)), name: .UIApplicationDidBecomeActive, object: nil)
    }

    deinit {

        // stop listening
        NotificationCenter.default.removeObserver(self)
    }

    ///////////////////////////////////////////////////////////
    // listeners
    ///////////////////////////////////////////////////////////

    func appDidBecomeActive(notification: Notification) {

        // app about to come to the foreground, either from initial launch or from background-to-foreground
        print(#function)

        // get current location
        getCurrentLocation()
    }

    ///////////////////////////////////////////////////////////
    // CLLocationManager
    ///////////////////////////////////////////////////////////

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // got an update - save
        guard locations.count > 0 else { return }

        // get new location
        let userLocation:CLLocation = locations[0] as CLLocation
        let newLocation = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)

        // make sure it has changed
        guard currentLocation != newLocation else { return }

        // save
        currentLocation = newLocation
        print("Device location: (\(currentLocation.latitude),\(currentLocation.longitude))")

        // stop any queue'd up requests
        locationManager.stopUpdatingLocation()

        // inform that valid location exists
        broadcastLocationUpdated()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        // error
        print("Location error: \(error)")
        broadcastLocationError(error: error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .authorizedWhenInUse {

            if previousLocationAuthStatus != nil {

                // now have access where we changed from some known value to authorized - fetch
                getCurrentLocation()
            }
        }
        else if status != .notDetermined {

            // ot determined or authorized, we're asking for permission ... 
            // when not doing that, give user option to update via settings
            UIAlertController.showLocationAlert()
        }

        // save previous status
        previousLocationAuthStatus = status
    }

    ///////////////////////////////////////////////////////////
    // api
    ///////////////////////////////////////////////////////////
    
    func clear() {

        NSLock().synchronized { [unowned self] in

            // clear cache
            self.gifManager = SwiftyGifManager(memoryLimit: Constants.swiftyGifMemoryLimit)
        }
    }

    func broadcastLocationUpdated() {

        // inform that valid location exists
        NotificationCenter.default.post(name: .drLocationUpdated, object: [ Notification.Name.Keys.locationUpdated : currentLocation ])
    }

    func broadcastLocationError(error: String) {

        // inform that location error occured
        NotificationCenter.default.post(name: .drLocationError, object: [ Notification.Name.Keys.locationError : error ])
    }

    private func getCurrentLocation() {

        let currentStatus = CLLocationManager.authorizationStatus()

        if currentStatus == .authorizedWhenInUse {

            // request a single quick update
            locationManager.requestLocation()
        }
        else if currentStatus == .notDetermined {

            // request access, check on auth change to continue
            locationManager.requestWhenInUseAuthorization()
        }
        else if currentStatus == .denied || currentStatus == .restricted {

            UIAlertController.showLocationAlert()
        }
    }
}
