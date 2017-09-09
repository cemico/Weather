//
//  UIViewController_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UIViewController {

    var isVisible: Bool {

        return self.isViewLoaded && (self.view.window != nil)
    }
}
