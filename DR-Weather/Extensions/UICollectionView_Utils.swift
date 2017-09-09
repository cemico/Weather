//
//  UICollectionView_Utils.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/7/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

extension UICollectionView {

    enum ReloadSpringRootDirection {

        case fromRight
    }

    func reloadData(with springRoot: ReloadSpringRootDirection) {

        //
        // idea is to reload the data, grab and loop through current visible cells,
        // move each to the bottom and spring animate each bottom cell back into position
        //

        // reload
        self.reloadData()

        // wait for cells to appear, unlike tableView, not ready immediately afterwards
        springCells(with: springRoot, currentCount: 1)
    }

    private func springCells(with springRoot: ReloadSpringRootDirection, currentCount: Int, maxCount: Int = 40, delaySeconds: Double = 0.1) {

        // check for timeout
        guard currentCount < maxCount else { print(#function, "timed out"); return }

        // wait for visible cells with timeout
        if self.visibleCells.count <= 0 {

            print("Waiting for visible collection cells...\(currentCount) of \(maxCount)")

            // wait
            let fireTime = DispatchTime.now() + delaySeconds
            DispatchQueue.main.asyncAfter(deadline: fireTime, execute: {

                self.springCells(with: springRoot, currentCount: currentCount + 1, maxCount: maxCount, delaySeconds: delaySeconds)
            })
            return
        }

        struct Constants {

            static let animationDuration                = TimeInterval(1.0)
            static let animationDelayFactor             = TimeInterval(0.02)
            static let animationSpringDampening         = CGFloat(0.8)
            static let animationInitialSpringVelocity   = CGFloat(0)
        }

        // grab visible cells
        print("Found for visible collection cells on iteration \(currentCount) of \(maxCount)")
        let cells = self.visibleCells

        var cellOffset: CGFloat
        var transform: CGAffineTransform

        switch springRoot {

            case .fromRight:
                cellOffset = self.bounds.size.width
                transform = CGAffineTransform(translationX: cellOffset, y: 0)
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
