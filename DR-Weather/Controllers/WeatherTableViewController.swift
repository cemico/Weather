//
//  WeatherTableViewController.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/11/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit
import SwiftyGif
import EZSwiftExtensions
import CoreLocation

class WeatherTableViewController: UIViewController {

    ///////////////////////////////////////////////////////////
    // outlets
    ///////////////////////////////////////////////////////////

    // loading indicator view [todo: move to nib]
    @IBOutlet weak var loadingView: LoadingView!

    // top and scroll container
    @IBOutlet weak var containerView: UIView!

    // top header
    @IBOutlet weak var headerView: UIView!

    // scroll container
    @IBOutlet weak var weatherTableView: WeatherTableView!

    // hourly collection - always below header
    @IBOutlet weak var hourlyCollectionView: HourlyCollectionView!
    @IBOutlet weak var hourlyCollectionFlowLayout: HourlyCollectionFlowLayout!
    @IBOutlet var hourlyCollectionContainer: UIView!

    // daily table - portrait under hourly collection, landscape under and on left side
    @IBOutlet weak var dailyTableView: DailyTableView!

    // conditions table - portrait under summary label, landscape under hourly collection on right side
    @IBOutlet weak var conditionsTableView: ConditionsTableView!

    // city - portrait centered in header, landscape top/left
    @IBOutlet weak var cityLabel: UILabel! {

        didSet {

            cityLabel.text = WeatherDataController.sharedInstance.weather?.location.city
        }
    }

    // condition - portrait centered in header, landscape under temp on right side
    @IBOutlet weak var conditionLabel: UILabel! {

        didSet {

            conditionLabel.text = WeatherDataController.sharedInstance.weather?.currentObservation.weatherCondition
        }
    }

    // temperature - portrait centered in header, landscape top/right
    @IBOutlet weak var currentTempLabel: UILabel! {

        didSet {

            currentTempLabel.text = WeatherDataController.sharedInstance.weather?.currentObservation.tempF
        }
    }

    ///////////////////////////////////////////////////////////
    // data members
    ///////////////////////////////////////////////////////////

    // data populated from online weather source
    fileprivate var hours: [WeatherDataController.HourAggregate] = []
    fileprivate var days: [WeatherDataController.DayAggregate] = []
    fileprivate var conditions: [WeatherDataController.ConditionAggregate] = []

    // dynamic scroll adjustments
    fileprivate var minHeight = CGFloat(0)
    fileprivate var maxHeight = CGFloat(0)

    ///////////////////////////////////////////////////////////
    // system overrides
    ///////////////////////////////////////////////////////////

    override func viewDidLoad() {
        super.viewDidLoad()

        print("\(#function)")

        // start listeninng right away
        NotificationCenter.default.addObserver(self, selector: #selector(weatherUpated(notification:)), name: .drWeatherUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpated(notification:)), name: .drLocationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationError(notification:)), name: .drLocationError, object: nil)

        // get rid of the bottom empty table rows
        dailyTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        conditionsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ease in to our display
        containerView.alpha = 0
        hourlyCollectionView.isHidden = true

        // setup display
        if loadingView.text.isEmpty {

            loadingView.text = "Retrieving location..."
        }

        if loadingView.isHidden {

            loadingView.start()
            loadingView.isHidden = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if isLandscape() {

            syncToCurrentDeviceOrientation()
        }

        if let text = cityLabel.text, !text.isEmpty {

            // data has arrived before display
            fadeDisplayIn()
        }

        // setup scroll limits
        syncMinMaxSwipeUpSpace()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // update on rotate
//        hourlyCollectionFlowLayout.invalidateLayout()

        coordinator.animate(alongsideTransition: { _ in

            // reset scroll
            self.weatherTableView.contentOffset.y = 0
            self.currentTempLabel.alpha = 1

        }) { _ in

            // rotation complete
            self.syncMinMaxSwipeUpSpace()

            let offset = self.maxHeight - self.headerView.frame.size.height
            if  offset > 0 {

                // reset to max / starting pos
                self.headerView.frame.size.height += offset
                self.weatherTableView.frame.origin.y += offset
                self.weatherTableView.frame.size.height -= offset
                self.weatherTableView.contentOffset.y = 0
            }

            // handle rotation for non-sizing class items, i.e. text alignment
            self.syncToCurrentDeviceOrientation()

            // different cells per rotation
            self.weatherTableView.reloadData()
            self.conditionsTableView.reloadData()
        }
    }

    deinit {

        // stop listening
        NotificationCenter.default.removeObserver(self)
    }

    ///////////////////////////////////////////////////////////
    // notifications
    ///////////////////////////////////////////////////////////

    func weatherUpated(notification: Notification) {

        // conditional update based on what data was requested / returned from server
        if let options = notification.userInfo?[Notification.Name.Keys.featureEnums] as? [Router.WeatherPathOptions] {

            // location data
            if options.contains(.geolookup),
                let location = WeatherDataController.sharedInstance.location {

                cityLabel.text = location.city
            }

            // current data
            if options.contains(.conditions),
                let current = WeatherDataController.sharedInstance.currentObservation {

                conditionLabel.text = current.weatherCondition
                //                currentTempLabel.setDegree(text: current.tempF)
                currentTempLabel.text = " \(current.tempF)\(String.degreeSymbol)"

                // pulse new value
                currentTempLabel.pulse()
            }
        }

        if isVisible {

            // data arrived after display was shown, update
            fadeDisplayIn()
        }

    }

    func locationUpated(notification: Notification) {

        print(#function)

        // we got our current location
        //        guard let coord = notification.userInfo?[Notification.Name.Keys.locationUpdated] as? CLLocationCoordinate2D else { return }

        // get current weather
        loadCurrentWeather()
    }

    func locationError(notification: Notification) {

        // error, not going to use devices location, use our fixed default
        UIAlertController.showOK(with: "Location Error", and: "Unable to retrieve the location from the device, using default location.")

        // get current weather
        loadCurrentWeather()
    }

    ///////////////////////////////////////////////////////////
    // helpers
    ///////////////////////////////////////////////////////////

    func reloadData() {

        // update local cache
        hours = WeatherDataController.sharedInstance.getHourlyAggregate()
        days = WeatherDataController.sharedInstance.getDailyAggregate()
        conditions = WeatherDataController.sharedInstance.getConditionsAggregate()

        hourlyCollectionView.reloadData(with: .fromRight)
        dailyTableView.reloadData(with: .fromBottom)
        conditionsTableView.reloadData()
        weatherTableView.reloadData()
    }

    private func loadCurrentWeather() {

        // update display
        loadingView.text = "Loading weather..."

        // background weather fetch for this new location
        WeatherDataController.sharedInstance.getWeather() { [weak self] _ in

            self?.fadeDisplayIn()
        }
    }

    func fadeDisplayIn() {

        guard self.containerView.alpha == 0 else { return }

//        // temp test
//        if self.containerView.alpha < 1 {
//
//            // perform second focused server fetch
//            WeatherDataController.sharedInstance.getWeather(with: [.conditions]) { success in
//
//                print("focused server request for '\(Router.WeatherPathOptions.conditions.rawValue)', results: \(success)")
//            }
//        }

        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {

                        self.containerView.alpha = 1.0
                        self.loadingView.alpha = 0
        },
                       completion: { _ in

                        // hidden stops spinner
                        self.loadingView.isHidden = true
                        self.loadingView.alpha = 1

                        // show data
                        self.reloadData()
        })
    }

    func syncMinMaxSwipeUpSpace() {

        if isLandscape() {

            // space more constrainted in landscape, allow min top to be just under lowest label
            minHeight = conditionLabel.frame.maxY + 5

            // max puts city centered on y space
            maxHeight = containerView.frame.size.height / 4
        }
        else {

            // portrait use half
            maxHeight = containerView.frame.midY
            minHeight = conditionLabel.frame.maxY
        }

        // reset to top
        weatherTableView.contentOffset.y = 0
    }

    func syncToCurrentDeviceOrientation() {

        // not all properties are tied to sizing classes ... manually update text orientations
        if isLandscape() {

            // landscape - mixed alignmet
            cityLabel.textAlignment = .left
//            currentTempLabel.textAlignment = .right
//            conditionLabel.textAlignment = .right
        }
        else {

            // portrait - all centered
            [cityLabel, currentTempLabel, conditionLabel].forEach({ $0.textAlignment = .center })
        }
    }

    func isLandscape() -> Bool {

        return UIDevice.current.orientation.isLandscape
    }
}

//
// table support
//

extension WeatherTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard tableView == weatherTableView else { return nil }

        return hourlyCollectionContainer
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        guard tableView == weatherTableView else { return 0 }

        return hourlyCollectionContainer.frame.size.height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let topView = headerView else { return }
        guard let bottomView = weatherTableView else { return }

        //        print(collectionView.contentOffset)
        let offset = bottomView.contentOffset.y

        // be sure don't shrink smaller than minimum
        guard topView.frame.size.height - offset >= minHeight else {

            // pin at minimum
            if topView.frame.size.height != minHeight {

                topView.frame.size.height = minHeight
                bottomView.frame.origin.y = minHeight
                bottomView.frame.size.height = view.frame.size.height - minHeight
                //                print("header height: \(topView.frame.size.height)")

                if !isLandscape() {

                    currentTempLabel.alpha = 0
                }
            }
            return
        }

        // max height check
        guard topView.frame.size.height - offset <= maxHeight else {

            // pin at max
            if topView.frame.size.height != maxHeight {

                topView.frame.size.height = maxHeight
                bottomView.frame.origin.y = maxHeight
                bottomView.frame.size.height = view.frame.size.height - maxHeight
                //                print("header height: \(topView.frame.size.height)")
                currentTempLabel.alpha = 1
            }
            return
        }

        // sanity
        guard offset != 0 else { return }

        topView.frame.size.height -= offset
        bottomView.frame.origin.y -= offset
        bottomView.frame.size.height += offset
        bottomView.contentOffset.y = 0
        //        print("header height: \(topView.frame.size.height)")

        guard !isLandscape() else { return }
        if bottomView.frame.minY <= currentTempLabel.frame.maxY {

            // passed bottom of temp label
            let diff = currentTempLabel.frame.maxY - bottomView.frame.minY
            let alphaZone = currentTempLabel.frame.size.height * 0.9

            // alpha down as pass over
            currentTempLabel.alpha = 1 - (min(1, diff / alphaZone))
        }
        else {

            currentTempLabel.alpha = 1
        }
    }
}

extension WeatherTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == dailyTableView || tableView == conditionsTableView {

            return 9
        }

        // weather table
        return isLandscape() ? 2 : 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if tableView == dailyTableView || tableView == conditionsTableView {

            return 30
        }

        // weather table
        if isLandscape() {

            // landscape
            // row 0 = dual table, 270
            // row 1 = summary, 40

            switch indexPath.row {

                case 1:
                    // summary
                    return 40

                case 0:     fallthrough
                default:
                    // daily and conditions
                    return 270
            }
        }
        else {

            // portrait
            // row 0 = daily table, 270
            // row 1 = summary, 50
            // row 2 = conditions table, 270

            switch indexPath.row {

            case 2:
                // conditions
                return 270

            case 1:
                // summary
                return 50

            case 0:     fallthrough
            default:
                // daily
                return 270
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == weatherTableView {

            if isLandscape() {

                // landscape
                // row 0 = dual table
                // row 1 = summary

                switch indexPath.row {

                    case 1:
                        // summary
                        return getSummaryCell(for: indexPath)

                    case 0:     fallthrough
                    default:
                        // daily and conditions
                        return getDailyAndConditionsCell(for: indexPath)
                }
            }
            else {

                // portrait
                // row 0 = daily table
                // row 1 = summary
                // row 2 = conditions table

                switch indexPath.row {

                    case 2:
                        // conditions
                        return getConditionsCell(for: indexPath)

                    case 1:
                        // summary
                        return getSummaryCell(for: indexPath)

                    case 0:     fallthrough
                    default:
                        // daily
                        return getDailyCell(for: indexPath)
                }
            }
        }
        else if tableView == dailyTableView {

            let cell = tableView.dequeueReusableCell(withIdentifier: DailyTableViewCell.self().className, for: indexPath)

            if let cell = cell as? DailyTableViewCell, indexPath.row < days.count {

                let data = days[indexPath.row]
                cell.update(data: data)
            }

            return cell
        }
        else if tableView == conditionsTableView {

            if isLandscape() {

                let cell = tableView.dequeueReusableCell(withIdentifier: ConditionsLandscapeTableViewCell.self().className, for: indexPath)

                if let cell = cell as? ConditionsLandscapeTableViewCell, indexPath.row < conditions.count {

                    let data = conditions[indexPath.row]
                    cell.update(data: data)
                }

                return cell
            }
            else {

                let cell = tableView.dequeueReusableCell(withIdentifier: ConditionsPortraitTableViewCell.self().className, for: indexPath)

                if let cell = cell as? ConditionsPortraitTableViewCell, indexPath.row < conditions.count {

                    let data = conditions[indexPath.row]
                    cell.update(data: data)
                }

                return cell
            }
        }

        assert(false, "Unhandled Table Cell")
    }

    private func getDailyCell(for indexPath: IndexPath) -> UITableViewCell {

        let cell = weatherTableView.dequeueReusableCell(withIdentifier: WeatherDailyTableViewCell.self().className, for: indexPath)

        if let cell = cell as? WeatherDailyTableViewCell {

            // attach table
            cell.tableView = dailyTableView
        }

        return cell
    }

    private func getConditionsCell(for indexPath: IndexPath) -> UITableViewCell {

        let cell = weatherTableView.dequeueReusableCell(withIdentifier: WeatherConditionsTableViewCell.self().className, for: indexPath)

        if let cell = cell as? WeatherConditionsTableViewCell {

            // attach table
            cell.tableView = conditionsTableView
        }

        return cell
    }

    private func getDailyAndConditionsCell(for indexPath: IndexPath) -> UITableViewCell {

        let cell = weatherTableView.dequeueReusableCell(withIdentifier: WeatherDailyAndConditionsTableViewCell.self().className, for: indexPath)

        if let cell = cell as? WeatherDailyAndConditionsTableViewCell {

            // attach tables
            cell.tableView = dailyTableView
            cell.tableView2 = conditionsTableView
        }

        return cell
    }

    private func getSummaryCell(for indexPath: IndexPath) -> UITableViewCell {

        let cell = weatherTableView.dequeueReusableCell(withIdentifier: WeatherSummaryTableViewCell.self().className, for: indexPath)

        if let cell = cell as? WeatherSummaryTableViewCell {

            let summary = WeatherDataController.sharedInstance.daySummary
            cell.update(summary: summary)
        }

        return cell
    }
}

//
// collection support
//

extension WeatherTableViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        // section collection
        return hours.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // section collection
        let data = hours[indexPath.row]
        if indexPath.row == 0 {

            // now is first item
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyNowCollectionViewCell.self().className, for: indexPath)

            if let cell = cell as? HourlyNowCollectionViewCell {

                cell.update(data: data)
            }

            return cell
        }
        else {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCollectionViewCell.self().className, for: indexPath)
            
            if let cell = cell as? HourlyCollectionViewCell {
                
                cell.update(data: data)
            }
            
            return cell
        }
    }
}

extension WeatherTableViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // default for types "now" and "default"
        var size = self.hourlyCollectionFlowLayout.itemSize
        let data = hours[indexPath.row]
        
        if data.type == .sunrise || data.type == .sunset {
            
            // slightly wider labels, make these types bit bigger
            size.width += 20
        }
        
        return size
    }
}
