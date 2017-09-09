//
//  Double_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import Foundation

extension Double {

    func asString(numDecimals: Int = 0)  -> String {

        return String(format: "%.\(numDecimals)f", self)
    }
}
