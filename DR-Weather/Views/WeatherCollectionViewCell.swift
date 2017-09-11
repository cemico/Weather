//
//  WeatherTableViewCell.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dailyContainerView: UIView!
    @IBOutlet weak var conditionsContainerView: UIView!
    @IBOutlet weak var summaryLabel: UILabel!
    
    weak var dailyTableView: UITableView? {

        didSet {

            if let tableView = dailyTableView {

                dailyContainerView.backgroundColor = UIColor.red
                tableView.frame = dailyContainerView.bounds
                tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                tableView.translatesAutoresizingMaskIntoConstraints = true
                dailyContainerView.addSubview(tableView)
            }
        }
    }

    weak var conditionsTableView: UITableView? {

        didSet {

            if let tableView = conditionsTableView {

                conditionsContainerView.backgroundColor = UIColor.yellow
                tableView.frame = conditionsContainerView.bounds
                tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                tableView.translatesAutoresizingMaskIntoConstraints = true
                conditionsContainerView.addSubview(tableView)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // early init
    }

    override func prepareForReuse() {

        // decouple outlets
        dailyTableView?.removeFromSuperview()
        dailyTableView = nil
        conditionsTableView?.removeFromSuperview()
        conditionsTableView = nil
    }
    
    func update(summary: String) {

        // single row - no need in passing in data, grab externally
        summaryLabel.text = summary
    }
}

class WeatherCollectionSectionView: UICollectionReusableView {

    weak var collectionView: UICollectionView? {

        didSet {

            if let cv = collectionView {

                cv.frame = self.bounds
                cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addSubview(cv)
            }
         }
    }
    weak var collectionFlowLayout: UICollectionViewFlowLayout?

    override func prepareForReuse() {

        // decouple outlets
        collectionView?.removeFromSuperview()
        collectionView = nil
        collectionFlowLayout = nil
    }
}
