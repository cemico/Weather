//
//  DailyTableViewCell.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hiTempLabel: UILabel!
    @IBOutlet weak var loTempLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func update(data: WeatherDataController.DayAggregate) {

        dayLabel.text = data.day
        hiTempLabel.text = data.hiTemp
        loTempLabel.text = data.loTemp
        if let gifImage = data.iconUrl.gifImageFromUrlString() {

            conditionImageView.setGifImage(gifImage)
        }
    }
}
