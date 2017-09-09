//
//  WeatherViewController.swift
//  DR-Weather
//
//  Created by Dave Rogers on 9/5/17.
//  Copyright © 2017 Cemico. All rights reserved.
//

import UIKit
import SwiftyGif
import CoreLocation

class WeatherViewController: UIViewController {

    // update back to "private" in Xcode 9
    fileprivate struct Constants {

        static let reuseIdentifier = "cell"
    }

    @IBOutlet weak var loadingView: LoadingView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var hourlyCollectionFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var dailyTableView: UITableView!
    @IBOutlet weak var conditionsTableView: UITableView!
    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var cityLabel: UILabel! {

        didSet {

            cityLabel.text = WeatherDataController.sharedInstance.weather?.location.city
        }
    }
    @IBOutlet weak var conditionLabel: UILabel! {

        didSet {

            conditionLabel.text = WeatherDataController.sharedInstance.weather?.currentObservation.weatherCondition
        }
    }
    @IBOutlet weak var currentTempLabel: UILabel! {

        didSet {

            currentTempLabel.text = WeatherDataController.sharedInstance.weather?.currentObservation.tempF
        }
    }

    fileprivate var hours: [WeatherDataController.HourAggregate] = []
    fileprivate var days: [WeatherDataController.DayAggregate] = []
    fileprivate var conditions: [WeatherDataController.ConditionAggregate] = []

    fileprivate var minHeight = CGFloat(0)
    fileprivate var maxHeight = CGFloat(0)


    override func viewDidLoad() {
        super.viewDidLoad()

        print("\(#function)")

        // start listeninng right away
        NotificationCenter.default.addObserver(self, selector: #selector(weatherUpated(notification:)), name: .drWeatherUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpated(notification:)), name: .drLocationUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationError(notification:)), name: .drLocationError, object: nil)

        // sticky collection headers
        collectionFlowLayout.sectionHeadersPinToVisibleBounds = true

        // get rid of the bottom empty rows
        dailyTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        conditionsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))

//        let dict = ["temp_f" : 92.3]
//        let co = CurrentObservation(attributes: dict)
//        let temp = co.getDoubleByKey("temp_f")
//        let desc = String(format: "%.1f", temp)
//        print(desc)


//        let name = "nt_clear"
//        let image = UIImage(gifName: name)
        
//        // test of degree symbol, need to attribute text make it about 1/6 font size
//        currentTempLabel.text = "80\u{00B0}"

//        let text = "357"
//        currentTempLabel.setDegree(text: text)

        // location test
//        let dictLocation: DaveAttributes = ["city" : "San Jose",
//                                            "country" : "US",
//                                            "lat" : "38.400000",
//                                            "lon" : "-121.370000",
//                                            "tz_long" : "America/Los_Angeles"
//        ]
//        let location = Location(attributes: dictLocation)
//        print(location.city, location.country, location.latitude, location.longitude, location.timezone)

//        let dictWeather: DaveAttributes = ["location" : dictLocation]
//        let weather = Weather(attributes: dictWeather)
//        print(weather.location, weather.location.city)

//        WeatherDataController.sharedInstance.getWeather()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ease in to our display
        containerView.alpha = 0

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

        if UIDevice.current.orientation.isLandscape {

            syncToCurrentDeviceOrientation()
        }

        if let text = cityLabel.text, !text.isEmpty {

            // data has arrived before display
            print("from viewDidAppear")
            fadeDisplayIn()
        }

        setMinMaxSwipeUpSpace()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        // handle rotation for non-sizing class items, i.e. text alignment
        syncToCurrentDeviceOrientation()

        coordinator.animate(alongsideTransition: { _ in

            // reset scroll 
            self.collectionView.contentOffset.y = 0
            self.currentTempLabel.alpha = 1

        }) { _ in

            // rotation complete
//            print("sync", self.headerView.frame)
            self.setMinMaxSwipeUpSpace()

            let offset = self.maxHeight - self.headerView.frame.size.height
            if  offset > 0 {

                // reset to max / starting pos
                self.headerView.frame.size.height += offset
                self.collectionView.frame.origin.y += offset
                self.collectionView.frame.size.height -= offset
                self.collectionView.contentOffset.y = 0
            }
        }
    }

    func syncToCurrentDeviceOrientation() {

        // not all properties are tied to sizing classes ... manually update text orientations
        if UIDevice.current.orientation.isLandscape {

            // landscape - mixed alignmet
            cityLabel.textAlignment = .left
            currentTempLabel.textAlignment = .right
            conditionLabel.textAlignment = .right
        }
        else {

            // portrait - all centered
            [cityLabel, currentTempLabel, conditionLabel].forEach({ $0.textAlignment = .center })
        }

        // have collection re-layout
//        hourlyCollectionFlowLayout.invalidateLayout()
        collectionFlowLayout.invalidateLayout()
    }

    func setMinMaxSwipeUpSpace() {

        if UIDevice.current.orientation.isLandscape {

            // space more constrainted in landscape, allow min top to be just under lowest label
            minHeight = conditionLabel.frame.maxY

            // max puts city centered on y space
            maxHeight = cityLabel.frame.midY * 2
        }
        else {

            // portrait use half
            maxHeight = containerView.frame.midY
            minHeight = conditionLabel.frame.maxY
        }
    }
    
    deinit {

        // stop listening
        NotificationCenter.default.removeObserver(self)
    }

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
            print("from data update")
            fadeDisplayIn()
        }

//        // testing
//        guard let weather = notification.object as? Weather else { return }
//        let co = weather.currentObservation
//        print(co.debugDescription)
//
//        let loc = weather.location
//        print(loc.debugDescription)
//
//        let hf = weather.hourForecast
//        print(hf.debugDescription)
//
//        let df = weather.dayForecast
//        print(df.debugDescription)
//
//        let mp = weather.moonPhase
//        print(mp.debugDescription)
//
//        print(weather.debugDescription)
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

    func loadCurrentWeather() {

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

    func reloadData() {

        // update local cache
        hours = WeatherDataController.sharedInstance.getHourlyAggregate()
        days = WeatherDataController.sharedInstance.getDailyAggregate()
        conditions = WeatherDataController.sharedInstance.getConditionsAggregate()

        collectionView.reloadData()
        hourlyCollectionView.reloadData(with: .fromRight)
        dailyTableView.reloadData(with: .fromBottom)
        conditionsTableView.reloadData()
    }
}

// keep things bit cleaner
extension WeatherViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if collectionView == self.collectionView {

            return 1
        }

        // section collection
        return hours.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == self.collectionView {

            // main collection
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier, for: indexPath)

            if let cell = cell as? WeatherCollectionViewCell {

                // attach
                cell.dailyTableView = dailyTableView
                cell.conditionsTableView = conditionsTableView

                // update
                cell.update(summary: WeatherDataController.sharedInstance.daySummary)
            }
            
            return cell
        }

        // section collection
        let data = hours[indexPath.row]
        if indexPath.row == 0 {

            // now is first item
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyNowCollectionViewCell", for: indexPath)

            if let cell = cell as? HourlyNowCollectionViewCell {

                cell.update(data: data)
            }
            
            return cell
        }
        else {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCollectionViewCell", for: indexPath)

            if let cell = cell as? HourlyCollectionViewCell {

                cell.update(data: data)
            }
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {

            case UICollectionElementKindSectionHeader:

                let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                 withReuseIdentifier: WeatherCollectionSectionView.Constants.reuseIdentifier,
                                                                                 for: indexPath) as! WeatherCollectionSectionView
                // attach
                sectionView.collectionFlowLayout = hourlyCollectionFlowLayout
                sectionView.collectionView = hourlyCollectionView
                return sectionView

            default:
                assert(false, "Unexpected element kind")
        }
    }
}

extension WeatherViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //        print(collectionView.contentOffset)
        let offset = collectionView.contentOffset.y

        // be sure don't shrink smaller than minimum
        guard headerView.frame.size.height - offset >= minHeight else {

            // pin at minimum
            if headerView.frame.size.height != minHeight {

                headerView.frame.size.height = minHeight
                collectionView.frame.origin.y = minHeight
                collectionView.frame.size.height = view.frame.size.height - minHeight
//                print("header height: \(headerView.frame.size.height)")
                currentTempLabel.alpha = 0
            }
            return
        }

        // max height check
        guard headerView.frame.size.height - offset <= maxHeight else {

            // pin at max
            if headerView.frame.size.height != maxHeight {

                headerView.frame.size.height = maxHeight
                collectionView.frame.origin.y = maxHeight
                collectionView.frame.size.height = view.frame.size.height - maxHeight
//                print("header height: \(headerView.frame.size.height)")
                currentTempLabel.alpha = 1
            }
            return
        }

        // sanity
        guard offset != 0 else { return }

        headerView.frame.size.height -= offset
        collectionView.frame.origin.y -= offset
        collectionView.frame.size.height += offset
        collectionView.contentOffset.y = 0
//        print("header height: \(headerView.frame.size.height)")

        if collectionView.frame.minY <= currentTempLabel.frame.maxY {

            // passed bottom of temp label
            let diff = currentTempLabel.frame.maxY - collectionView.frame.minY
            let alphaZone = currentTempLabel.frame.size.height * 0.9

            // alpha down as pass over
            currentTempLabel.alpha = 1 - (min(1, diff / alphaZone))
        }
        else {

            currentTempLabel.alpha = 1
        }
    }
}

extension WeatherViewController: UICollectionViewDelegate {

}

extension WeatherViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == self.collectionView {

            let width = containerView.bounds.width - collectionFlowLayout.sectionInset.left - collectionFlowLayout.sectionInset.right
            var height = collectionFlowLayout.itemSize.height
            if UIDevice.current.orientation.isLandscape {

                // 270 table + 40 label
                height = 310
            }

            let newSize = CGSize(width: width, height: height)
            print("newSize: \(newSize)")
            return newSize
        }
        else if collectionView == hourlyCollectionView {

            // default for types "now" and "default"
            var size = self.hourlyCollectionFlowLayout.itemSize
            let data = hours[indexPath.row]

            if data.type == .sunrise || data.type == .sunset {

                // slightly wider labels, make these types bit bigger
                size.width += 20
            }

            return size
        }

        return collectionFlowLayout.itemSize
    }
}

extension WeatherViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == dailyTableView {

            return days.count
        }

        return min(days.count, conditions.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == dailyTableView {

            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyTableViewCell", for: indexPath)

            if let cell = cell as? DailyTableViewCell {

                let data = days[indexPath.row]
                cell.update(data: data)
            }
            
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ConditionsTableViewCell", for: indexPath)

        if let cell = cell as? ConditionsTableViewCell {

            let data = conditions[indexPath.row]
            cell.update(data: data)
        }

        return cell
    }
}

extension WeatherViewController: UITableViewDelegate {

}
