//
//  ConditionsTableViewCell.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class ConditionsTableViewCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func update(data: WeatherDataController.ConditionAggregate) {

        keyLabel.text = data.key + ":"
        valueLabel.text = data.value
    }
}
