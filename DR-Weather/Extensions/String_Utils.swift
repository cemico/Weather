//
//  String_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension String {

    var length: Int {

        return self.characters.count
    }

    func gifImageFromUrlString() -> UIImage? {

        let url = self as NSString
        let filename = url.lastPathComponent
        //        let asssetName = filename.deletingPathExtension
        //        return UIImage(named: asssetName)

        let gif = UIImage(gifName: filename)
        return gif
    }

    static var degreeSymbol: String = "\u{00B0}"
}
