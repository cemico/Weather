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
    @IBOutlet weak var keyLabelWidthLandscape: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func update(data: WeatherDataController.ConditionAggregate) {

        keyLabel.text = data.key + ":"
        valueLabel.text = data.value

        if UIDevice.current.orientation.isLandscape {

            // landscape is left aligned and sized to fit
            [keyLabel, valueLabel].forEach({ $0.textAlignment = .left })
            let fitSize = keyLabel.sizeThatFits(CGSize(width: bounds.size.width, height: keyLabel.frame.size.height))
            keyLabelWidthLandscape.constant = fitSize.width
        }
        else {

            setLabelsToPortrait()
        }
    }

    private func setLabelsToPortrait() {

        // portrait alignment
        let widthPercentage = CGFloat(0.48)
        [keyLabel, valueLabel].forEach({ $0.frame.size.width = bounds.size.width * widthPercentage })
        keyLabel.textAlignment = .right
        valueLabel.textAlignment = .left
    }
}
