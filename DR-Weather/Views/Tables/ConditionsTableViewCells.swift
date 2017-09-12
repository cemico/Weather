//
//  ConditionsTableViewCells.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class ConditionsPortraitTableViewCell: ConditionsBaseTableViewCell { }

class ConditionsLandscapeTableViewCell: ConditionsBaseTableViewCell {

    @IBOutlet weak var keyLabelWidthLandscape: NSLayoutConstraint!

    override func update(data: WeatherDataController.ConditionAggregate) {
        super.update(data: data)

        // size labels to fit
        let fitSize = keyLabel.sizeThatFits(CGSize(width: bounds.size.width, height: keyLabel.frame.size.height))
        keyLabelWidthLandscape.constant = fitSize.width
    }
}

class ConditionsBaseTableViewCell: UITableViewCell {

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
