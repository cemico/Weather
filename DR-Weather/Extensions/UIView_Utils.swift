//
//  UIView_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UIView {

    func pulse(for duration: TimeInterval = 2.0, and dampening: CGFloat = 0.2) {

        self.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)

        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: dampening,
            initialSpringVelocity: 0.0,
            animations: {

                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

        },
            completion:{_ in

        })
    }    
}
