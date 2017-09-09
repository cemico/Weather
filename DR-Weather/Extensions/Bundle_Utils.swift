//
//  Bundle_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Bundle {

    enum InfoItemTypes: String {

        case wundergroundApiKey = "WundergroundApiKey"
    }
    
    // convience wrapper to extrat info.plist values
    func infoValueOfType<T>(for key: InfoItemTypes) -> T? {

        // unwrap info dict
        guard let infoDict = infoDictionary else { return nil }

        // unwrap type
        guard let value = infoDict[key.rawValue] as? T else { return nil }

        return value
    }

    func stringInfoValue(for key: InfoItemTypes) -> String? {

        if let value: String = Bundle.main.infoValueOfType(for: key) {

            return value
        }

        return nil
    }
}

