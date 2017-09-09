//
//  UITableView_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UITableView {

    enum ReloadSpringRootDirection {

        case fromBottom
    }

    func reloadData(with springRoot: ReloadSpringRootDirection) {

        struct Constants {

            static let animationDuration                = TimeInterval(1.0)
            static let animationDelayFactor             = TimeInterval(0.02)
            static let animationSpringDampening         = CGFloat(0.5)
            static let animationInitialSpringVelocity   = CGFloat(0.2)
        }
        
        //
        // idea is to reload the data, grab and loop through current visible cells,
        // move each to the bottom and spring animate each bottom cell back into position
        //

        // reload
        self.reloadData()

        // grab visible cells
        let cells = self.visibleCells
        var cellOffset: CGFloat
        var transform: CGAffineTransform

        switch springRoot {

            case .fromBottom:
                cellOffset = self.bounds.size.height
                transform = CGAffineTransform(translationX: 0, y: cellOffset)
        }

        // move to offset
        for cell in cells {

            cell.transform = transform
        }

        // put back in place
        for (index, cell) in cells.enumerated() {

            UIView.animate(withDuration: Constants.animationDuration,
                           delay: Constants.animationDelayFactor * Double(index),
                           usingSpringWithDamping: Constants.animationSpringDampening,
                           initialSpringVelocity: Constants.animationInitialSpringVelocity,
                           options: [],
                           animations: {

                // restore position
                cell.transform = CGAffineTransform(translationX: 0, y: 0);

            }, completion: nil)
        }
    }
}
