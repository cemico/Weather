//
//  UIFont_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UIFont {

    func bold(pointSize: CGFloat) -> UIFont {

        // a new font only differing by adding bold trait
        let descriptor = self.fontDescriptor
        guard let boldDescriptor = descriptor.withSymbolicTraits([.traitBold]) else { return self }

        return UIFont(descriptor: boldDescriptor, size: pointSize)
    }
    
    func fontWithPointSize(pointSize: CGFloat) -> UIFont {

        // might already be at that point size
        guard self.pointSize != pointSize else { return self }

        // a new font only differing by point size
        return UIFont(descriptor: self.fontDescriptor, size: pointSize)
    }
}
