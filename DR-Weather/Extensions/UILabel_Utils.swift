//
//  UILabel_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UILabel {

    func setDegree(text degreeText: String, withPrefix: String = " ") {

        // add degree symbol (and space to offset degree to keep value in center)
        let combinedText = withPrefix + degreeText + String.degreeSymbol

        if let font = self.font {

            let fontText = font
            let ptSizeText = fontText.pointSize
            let ptSizeDegree = ptSizeText / 3
            let fontDegree = fontText.bold(pointSize: ptSizeDegree)

            // set text
            let textRange = NSRange(location: 0, length: combinedText.length - 1)
            let attrText = NSMutableAttributedString(string: combinedText, attributes: [NSFontAttributeName: fontText])
            attrText.addAttribute(NSForegroundColorAttributeName, value: self.textColor, range: textRange)

            // set degree
            let degreeRange = NSRange(location: combinedText.length - 1, length: 1)
            attrText.addAttributes([NSFontAttributeName: fontDegree], range: degreeRange)
            attrText.addAttribute(NSBaselineOffsetAttributeName, value: ptSizeDegree * 3 / 2, range: degreeRange)

            // update label
            self.attributedText = attrText
        }
        else {

            self.text = combinedText
        }
    }
}
