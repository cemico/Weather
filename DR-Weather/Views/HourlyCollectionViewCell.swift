//
//  HourlyCollectionViewCell.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        // early init
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // cleanup any items

        // reset to non-bold
    }

    func update(data: WeatherDataController.HourAggregate) {

        // single row - no need in passing in data, grab externally
        hourLabel.text = data.time
        tempLabel.text = data.tempOrLabel
        if let gifImage = data.iconUrl.gifImageFromUrlString() {

            imageView.setGifImage(gifImage)
        }
    }
}
