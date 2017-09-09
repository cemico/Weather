//
//  UIApplication_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UIApplication {

    enum SettingsSections: String {

        case privacy    = "Privacy"
        case wifi       = "WIFI"
        case bluetooth  = "Bluetooth"
        case general    = "General"
        case facebook   = "FACEBOOK"
        case twitter    = "TWITTER"
    }

    enum SettingsPrivacy: String {

        case location   = "LOCATION"
        case photos     = "PHOTOS"
        case camera     = "CAMERA"

        case root       = ""
    }

    func openSettingsPrivacy(type: SettingsPrivacy) {

        var path = ""

        if #available(iOS 10.0, *)
        {
            path = "App-Prefs:root=\(SettingsSections.privacy.rawValue)"
        }
        else
        {
            path = "prefs:root=\(SettingsSections.privacy.rawValue)"
        }

        // check optional type
        switch type {

        case .root:
            break

        default:
            path += "&path=\(type.rawValue)"
        }

        print("Settings path: \(path)")
        if let url = URL(string: path) {

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func openSettings(section: SettingsSections) {

        var path = ""

        if #available(iOS 10.0, *)
        {
            path = "App-Prefs:root=\(section.rawValue)"
        }
        else
        {
            path = "prefs:root=\(section.rawValue)"
        }

        print("Settings path: \(path)")
        if let url = URL(string: path) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    class var rootVC: UIViewController? {

        return UIApplication.shared.keyWindow?.rootViewController
    }
}
