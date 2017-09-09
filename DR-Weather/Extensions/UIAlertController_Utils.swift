//
//  UIAlertController_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UIAlertController {

    class func showLocationAlert(on vcHost: UIViewController? = nil) {

        var vcShow = vcHost
        if vcShow == nil,
        let vcRoot = UIApplication.rootVC {

            vcShow = vcRoot
        }

        // error, not going to use devices location, use our fixed default
        let alert = UIAlertController(title: "Location Access",
                                      message: "Unable to retrieve the GPS location of your device.  Check permissons in Settings to verify access is granted.  A default GPS location will be used.",
                                      preferredStyle: .alert)

        // setup buttons
        let settingsButton = UIAlertAction(title: "Settings", style: .default) { action in

            // launch settings
            UIApplication.shared.openSettingsPrivacy(type: .location)
        }

        let defaultButton = UIAlertAction(title: "Use Default", style: .default) { action in

            // use default value
            AppDataController.sharedInstance.broadcastLocationUpdated()

//            // test
//            AppDataController.sharedInstance.broadcastLocationError(error: "dave error")
        }

        // add buttons
        alert.addAction(settingsButton)
        alert.addAction(defaultButton)
        
        // show
        vcShow?.present(alert, animated: true, completion: nil)
    }

    class func showOK(on vcHost: UIViewController? = nil, with title: String, and message: String) {

        var vcShow = vcHost
        if vcShow == nil,
            let vcRoot = UIApplication.rootVC {

            vcShow = vcRoot
        }

        // simple one button alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // setup OK
        let okButton = UIAlertAction(title: "OK", style: .default)

        // add buttons
        alert.addAction(okButton)
        
        // show
        vcShow?.present(alert, animated: true, completion: nil)
    }
}
