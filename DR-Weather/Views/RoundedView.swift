//
//  RoundedView.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    private struct Constants {

        static let cornerRadius = CGFloat(8)
        static let borderWidth = CGFloat(0)
        static let borderColor = UIColor.black
    }

    var cornerRadius: CGFloat = Constants.cornerRadius {

        didSet {

            self.layer.cornerRadius = cornerRadius
        }
    }
    var borderWidth: CGFloat = Constants.borderWidth {

        didSet {

            self.layer.borderWidth = borderWidth
        }
    }

    var borderColor: UIColor = Constants.borderColor {

        didSet {

            self.layer.borderColor = borderColor.cgColor
        }
    }

    required init?(coder aDecoder: NSCoder) {

        // default handling
        super.init(coder: aDecoder)

        // clip all
        self.clipsToBounds = true
        self.layer.masksToBounds = true

        // default values
        if cornerRadius > 0 {

            self.layer.cornerRadius = cornerRadius
        }

        if borderWidth > 0 {

            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
