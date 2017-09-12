//
//  WeatherDailyTableViewCell.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/12/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class WeatherDailyTableViewCell: WeatherBaseTableViewCell { }

class WeatherConditionsTableViewCell: WeatherBaseTableViewCell { }

class WeatherDailyAndConditionsTableViewCell: WeatherBaseTableViewCell {

    // add support for second container and table
    @IBOutlet weak var containerView2: UIView!

    weak var tableView2: UITableView? {

        didSet {

            if let tableView2 = tableView2 {

                // attach table to this cell
                tableView2.frame = containerView2.bounds
                tableView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                tableView2.translatesAutoresizingMaskIntoConstraints = true
                containerView2.addSubview(tableView2)
            }
            else {

                // detach table from this cell
                oldValue?.removeFromSuperview()
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // release strong reference
        tableView2 = nil
    }
}

class WeatherBaseTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!

    weak var tableView: UITableView? {

        didSet {

            if let tableView = tableView {

                // attach table to this cell
                tableView.frame = containerView.bounds
                tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                tableView.translatesAutoresizingMaskIntoConstraints = true
                containerView.addSubview(tableView)
            }
            else {

                // detach table from this cell
                oldValue?.removeFromSuperview()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // release strong reference
        tableView = nil
    }
}

class WeatherSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var summaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func update(summary: String) {

        summaryLabel.text = summary
    }
}
