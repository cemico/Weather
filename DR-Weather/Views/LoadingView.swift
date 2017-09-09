//
//  LoadingView.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/6/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class LoadingView: RoundedView {

    // todo: pull out of storyboard and into xib for resuse
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet weak var textLabel: UILabel!

    ///////////////////////////////////////////////////////////
    // init and overrides
    ///////////////////////////////////////////////////////////

    required init(coder aDecoder: NSCoder) {

        // default handling
        super.init(coder: aDecoder)!

        // everything
        initAll()
    }

    override func layoutSubviews() {

        // default handling
        super.layoutSubviews()

        // views constructed and apart of the hierarchy
        autoSpinner()
    }

    private func initAll() {

        // inits specific for this mode
    }
    
    override var isHidden: Bool {

        didSet {

            autoSpinner()
        }
    }

    var text: String = "" {

        didSet {

            textLabel?.text = text
        }
    }

    private func autoSpinner() {

        if isHidden {

            // stop spinning on hide
            stop()
        }
        else {

            // start spinning on show
            start()
        }
    }

    func start() {

        spinnerView?.startAnimating()
    }

    func stop() {

        spinnerView?.stopAnimating()
    }
}
