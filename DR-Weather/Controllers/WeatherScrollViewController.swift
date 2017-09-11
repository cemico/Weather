//
//  WeatherScrollViewController.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/10/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit

class WeatherScrollViewController: UIViewController {

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
    @IBOutlet weak var scrollContainerView: UIScrollView!

    // hourly collection - always below header
    @IBOutlet weak var hourlyCollectionView: HourlyCollectionView!
    @IBOutlet weak var hourlyCollectionFlowLayout: HourlyCollectionFlowLayout!

    // daily table - portrait under hourly collection, landscape under and on left side
    @IBOutlet weak var dailyTableView: DailyTableView!

    // conditions table - portrait under summary label, landscape under hourly collection on right side
    @IBOutlet weak var conditionsTableView: ConditionsTableView!

    // summary - portrait sits between daily and condition table and bit taller, landscape sits at bottom
    @IBOutlet weak var summaryLabel: UILabel!

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
        hourlyCollectionFlowLayout.invalidateLayout()

        coordinator.animate(alongsideTransition: { _ in

            // reset scroll
            self.scrollContainerView.contentOffset.y = 0
            self.currentTempLabel.alpha = 1

        }) { _ in

            // rotation complete
            self.syncMinMaxSwipeUpSpace()

            let offset = self.maxHeight - self.headerView.frame.size.height
            if  offset > 0 {

                // reset to max / starting pos
                self.headerView.frame.size.height += offset
                self.scrollContainerView.frame.origin.y += offset
                self.scrollContainerView.frame.size.height -= offset
                self.scrollContainerView.contentOffset.y = 0
            }

            // handle rotation for non-sizing class items, i.e. text alignment
            self.syncToCurrentDeviceOrientation()

            // update dynamic cell sizing
//            self.conditionsTableView.reloadData()
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
        summaryLabel.text = WeatherDataController.sharedInstance.daySummary
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

            // summary label and border last item
            scrollContainerView.contentSize.height = summaryLabel.frame.maxY + 1
        }
        else {

            // portrait use half
            maxHeight = containerView.frame.midY
            minHeight = conditionLabel.frame.maxY

            // condition table last item
            scrollContainerView.contentSize = CGSize(width: containerView.frame.size.width, height:conditionsTableView.frame.maxY)
        }

        // reset to top
        scrollContainerView.contentOffset.y = 0
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

extension WeatherScrollViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard let topView = headerView else { return }
        guard let bottomView = scrollContainerView else { return }

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

extension WeatherScrollViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == dailyTableView {

            return days.count
        }

        return min(days.count, conditions.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == dailyTableView {

            let cell = tableView.dequeueReusableCell(withIdentifier: DailyTableViewCell.self().className, for: indexPath)

            if let cell = cell as? DailyTableViewCell {

                let data = days[indexPath.row]
                cell.update(data: data)
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: ConditionsTableViewCell.self().className, for: indexPath)

        if let cell = cell as? ConditionsTableViewCell {

            let data = conditions[indexPath.row]
            cell.update(data: data)
        }
        
        return cell
    }
}

extension WeatherScrollViewController: UICollectionViewDataSource {

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

extension WeatherScrollViewController: UICollectionViewDelegateFlowLayout {

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

// misc class definitions for debugging identification
class DailyTableView: UITableView { }
class ConditionsTableView: UITableView { }
class HourlyCollectionView: UICollectionView {

//    override var frame: CGRect {
//
//        willSet {
//
//            print("current: \(frame), new: \(newValue)")
//        }
//    }
}
class HourlyCollectionFlowLayout: UICollectionViewFlowLayout { }
