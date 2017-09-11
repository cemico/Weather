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

    var keyOriginalWidth = CGFloat(0)

    private var isLandscape: Bool {

        // status bar updates immediately on rotate whereas UIDevice.current.orientation.isLandscape has slight lag
        let orientation = UIApplication.shared.statusBarOrientation
        return (orientation == .landscapeLeft) || (orientation == .landscapeRight)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        keyLabelWidthLandscape.isActive = isLandscape
    }

    override func layoutSubviews() {
//        keyLabelWidthLandscape.isActive = isLandscape
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // since we have different sizing classes in place for the key width, need
        // to restore to prevent runtime constraint warnings
        if keyOriginalWidth > 0 {

            keyLabelWidthLandscape.constant = keyOriginalWidth
        }
//        keyLabelWidthLandscape.isActive = isLandscape
    }

    func update(data: WeatherDataController.ConditionAggregate) {

        keyLabel.text = data.key + ":"
        valueLabel.text = data.value

        if UIDevice.current.orientation.isLandscape {

            // landscape is left aligned and sized to fit
            [keyLabel, valueLabel].forEach({ $0.textAlignment = .left })
            let fitSize = keyLabel.sizeThatFits(CGSize(width: bounds.size.width, height: keyLabel.frame.size.height))

            // note: this value causes a runtime constraint issue when returning to portrait from landscape.
            //       it seems even though this is only declared in landscape sizing classes, it is being seen
            //       in portrait sizing classes when rotating from landscape
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
