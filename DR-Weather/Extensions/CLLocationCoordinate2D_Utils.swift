//
//  CLLocationCoordinate2D_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {

    func equalTo(_ selfTest: CLLocationCoordinate2D) -> Bool {

//        // object level compare, but we are a struct
//        guard self !== selfTest else { return true }

        // value level compare
        return (self.latitude == selfTest.latitude) && (self.longitude == selfTest.longitude)
    }
}

// global scope for equitable compares
public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {

    // call into class so class heirarchy is maintained
    return lhs.equalTo(rhs)
}
