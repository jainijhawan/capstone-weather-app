//
//  ViewController.swift
//  Weather App
//
//  Created by Jai Nijhawan on 01/10/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var allowLocationPermissionButton: UIButton!
    @IBOutlet weak var metricSegmentControl: UISegmentedControl!
    @IBOutlet weak var savedCityCollectionView: UICollectionView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    
    @IBOutlet weak var aqiCommentLabel: UILabel!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var backgroundAQIImageView: UIImageView!
    @IBOutlet weak var minimumTempLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentDayLabel: UILabel!
    @IBOutlet weak var maximumTempLabel: UILabel!
    @IBOutlet weak var metricLabel: UILabel!
    @IBOutlet weak var currentTempratureLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    var locationManager: CLLocationManager?
    let weatherService = WeatherServices.shared
    var cityDataDataSource = [SavedCityModel]()
    var hourlyCellModels = [HourlyWeatherCollectionViewCellModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        setDefaultVAlues()
        savedCityCollectionView.delegate = self
        savedCityCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        hourlyCollectionView.dataSource = self
        savedCityCollectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        hourlyCollectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        reloadCityList()
        allowLocationPermissionTapped(self)
    }
    
    func setDefaultVAlues() {
        [weatherConditionLabel,
         aqiLabel,
         minimumTempLabel,
         currentDateLabel,
         currentDayLabel,
         maximumTempLabel,
         metricLabel,
         currentTempratureLabel,
         cityNameLabel
        ].forEach { $0?.text = "-"}
    }
    
    func requestWeatherFor(lat: Double, lon: Double) {
        weatherService.getCurrentCityData(lat: lat, lon: lon) { isSuccess, weatherData in
            if isSuccess {
                DispatchQueue.main.async {
                    guard let weatherData = weatherData else { return }
                    self.setupUI(data: weatherData)
                }
            }
        }
    }
    func requestAQIFor(lat: Double, lon: Double) {
        weatherService.getCurrentLocationAQI(lat: lat, lon: lon) { isSuccess, AQIData in
            if isSuccess {
                DispatchQueue.main.async {
                    guard let AQIData = AQIData else { return }
                    self.setupUIforAQI(data: AQIData)
                    self.setupAQIComment(aqi: AQIData.overallAqi ?? 0)
                }
            }
        }
    }
    
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex != 1 {
            currentTempratureLabel.text = tempInCelcius(text: currentTempratureLabel.text)
            minimumTempLabel.text = tempInCelcius(text: String(minimumTempLabel.text?.dropLast(2) ?? "")) + "°C"
            maximumTempLabel.text = tempInCelcius(text: String(maximumTempLabel.text?.dropLast(2 ) ?? "")) + "°C"
            metricLabel.text = "°C"
        } else {
            currentTempratureLabel.text = tempInFahrenheit(text: currentTempratureLabel.text)
            minimumTempLabel.text = tempInFahrenheit(text: String(minimumTempLabel.text?.dropLast(2) ?? "")) + "°F"
            maximumTempLabel.text = tempInFahrenheit(text: String(maximumTempLabel.text?.dropLast(2) ?? "")) + "°F"
            metricLabel.text = "°F"
        }
        
        savedCityCollectionView.reloadData()
        hourlyCollectionView.reloadData()
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        vc .delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func allowLocationPermissionTapped(_ sender: Any) {
        // initialise a pop up for using later
        let alertController = UIAlertController(title: "To make the app get weather data", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        // check the permission status
        switch(locationManager?.authorizationStatus) {
        case .notDetermined:
            allowLocationPermissionButton.isHidden = false
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedAlways,
                .authorizedWhenInUse:
            print("Authorize.")
            allowLocationPermissionButton.isHidden = true
        case.restricted,
                .denied:
            // redirect the users to settings
            allowLocationPermissionButton.isHidden = false
            self.present(alertController, animated: true, completion: nil)
        case .none:
            break
        @unknown default:
            break
        }
    }
}

extension ViewController: UICollectionViewDelegate,
                          UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case savedCityCollectionView:
            return cityDataDataSource.count
        case hourlyCollectionView:
            return hourlyCellModels.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case hourlyCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:HourlyWeatherCollectionViewCell.self), for: indexPath) as? HourlyWeatherCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setupUI(viewModel: hourlyCellModels[indexPath.row], segmentControlIndex: metricSegmentControl.selectedSegmentIndex)
            return cell
        case savedCityCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:SavedCityCollectionViewCell.self), for: indexPath) as? SavedCityCollectionViewCell else {
                return UICollectionViewCell()
            }
            let city = cityDataDataSource[indexPath.row]
            cell.setupUI(segmentControlIndex: metricSegmentControl.selectedSegmentIndex, cityName: city.name, temp: city.temp)
            cell.setupAQI(aqi: city.aqi)
            return cell
        default:
            return UICollectionViewCell()
        }
 
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined,
                .restricted,
                .denied:
            allowLocationPermissionButton.isHidden = false
            
        case .authorizedAlways,
                .authorizedWhenInUse,
                .authorized:
            allowLocationPermissionButton.isHidden = true
            guard let locValue = manager.location?.coordinate else { return }
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            requestWeatherFor(lat: Double(locValue.latitude), lon: Double(locValue.longitude))
            requestAQIFor(lat: Double(locValue.latitude), lon: Double(locValue.longitude))
        @unknown default:
            break
        }
    }
}

extension ViewController {
    func setupUI(data: CurrentWeatherData) {
        currentTempratureLabel.animateWith(text: data.current.temp.getTempInCelcius())
        currentDayLabel.animateWith(text: Date().dayOfWeek() ?? "")
        currentDateLabel.animateWith(text: Date().getCurrentDate())
        metricLabel.animateWith(text: "°C")
        maximumTempLabel.animateWith(text: (data.daily.first?.temp.max.getTempInCelcius() ?? "") + "°C")
        minimumTempLabel.animateWith(text: (data.daily.first?.temp.min.getTempInCelcius() ?? "") + "°C")
        getCityName(lat: data.lat, lon: data.lon) { name in
            self.cityNameLabel.text = name
        }
        weatherConditionLabel.animateWith(text: data.current.weather.first?.weatherDescription.capitalized ?? "")
       createHourlyCellModels(data: data)
    }
    
    func getCityName(lat: Double, lon: Double,
                     completion: @escaping ((_ data: String) -> Void)) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                completion(placemarks?.first?.locality ?? "")
            }
        }
    }
    
    func createHourlyCellModels(data: CurrentWeatherData) {
      let dateFormatterPrint = DateFormatter()
      dateFormatterPrint.dateFormat = "h a"
      var models = [HourlyWeatherCollectionViewCellModel]()
      for index in 0...24 {
        let date = Date(timeIntervalSince1970: TimeInterval(data.hourly[index].dt))
        let timeString = dateFormatterPrint.string(from: date)
        let id = data.hourly[index].weather.first?.id
        let temp = data.hourly[index].temp.getTempInCelcius()
        
        if timeString == "1 AM" {
          models.append(HourlyWeatherCollectionViewCellModel(time: "",
                                                             id: 0,
                                                             temprature: "",
                                                             index: index, 
                                                             tempDouble: data.hourly[index].temp))
        }
        let model = HourlyWeatherCollectionViewCellModel(time: timeString,
                                                         id: id!,
                                                         temprature: temp + "°",
                                                         index: index, 
                                                         tempDouble: data.hourly[index].temp)
        models.append(model)
      }
      hourlyCellModels = models
      hourlyCollectionView.reloadData()
    }
    
    func setupUIforAQI(data: AQIDataModel) {
        guard let aqi = data.overallAqi else { return }
        aqiLabel.text = "AQI: \(aqi)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.transition(with: self.backgroundAQIImageView,
                              duration: 4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.backgroundAQIImageView.image = getAQIBG(aqi: Int(aqi))
            },
                              completion: nil)
        }
    }
}

protocol ViewControllerDelegate: AnyObject {
    func reloadCityList()
}

extension ViewController: ViewControllerDelegate {
    func reloadCityList() {
        cityDataDataSource.removeAll()
        cityDataDataSource = getSavedCities()
        getWeatherForSavedCities(cityList: cityDataDataSource)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoSearch",
           let destiNation = segue.destination as? SearchViewController {
            destiNation.delegate = self
        }
    }
}


extension ViewController {
    func getWeatherForSavedCities(cityList: [SavedCityModel]) {
        var cityListWithData: [SavedCityModel] = []
        cityList.forEach { city in
            weatherService.getCurrentCityData(lat: city.lat, lon: city.lon) { success, dataFromServer in
                if success,
                   let data = dataFromServer {
                    let temp: Double = data.current.temp
                    DispatchQueue.main.async {
                        cityListWithData.append(SavedCityModel(name: city.name, lat: city.lat, lon: city.lon, temp: temp))
                        
                        if cityListWithData.count == cityList.count {
                            self.matchCityNameandUpdateData(cityListWithData: cityListWithData)
                        }
                    }
                }
            }
        }
    }
    
    func matchCityNameandUpdateData(cityListWithData: [SavedCityModel]) {
        for i in 0..<cityDataDataSource.count {
            for j in 0..<cityListWithData.count {
                if cityDataDataSource[i].name == cityListWithData[j].name &&
                    cityDataDataSource[i].lat == cityListWithData[j].lat &&
                    cityDataDataSource[i].lon == cityListWithData[j].lon {
                    cityDataDataSource[i].temp = cityListWithData[j].temp
                    break  // If you found a match, exit the inner loop
                }
            }
        }
        
        self.savedCityCollectionView.reloadData()
        
        getAQIForAllCities(cityListWithData: cityListWithData)
    }
    
    func getAQIForAllCities(cityListWithData: [SavedCityModel]) {
        var temp = [SavedCityModel]()
        for city in cityListWithData {
            weatherService.getCurrentLocationAQI(lat: city.lat, lon: city.lon) { isSuccess, AQIData in
                if isSuccess {
                    DispatchQueue.main.async {
                        guard let AQIData = AQIData else { return }
                        var tempCity = city
                        tempCity.aqi = AQIData.overallAqi ?? 0
                        temp.append(tempCity)
                        
                        if temp.count == self.cityDataDataSource.count {
                            for i in 0..<self.cityDataDataSource.count {
                                for j in 0..<cityListWithData.count {
                                    if self.cityDataDataSource[i].name == temp[j].name &&
                                        self.cityDataDataSource[i].lat == temp[j].lat &&
                                        self.cityDataDataSource[i].lon == temp[j].lon {
                                        self.cityDataDataSource[i].temp = temp[j].temp
                                        self.cityDataDataSource[i].aqi = temp[j].aqi
                                        break  // If you found a match, exit the inner loop
                                    }
                                }
                            }

                        }
                        self.savedCityCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension ViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCity = cityDataDataSource[indexPath.row]
        
        let alert = UIAlertController(title: "Remove \(selectedCity.name) from favourites", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.cityDataDataSource.remove(at: indexPath.row)
            removeCityFromDatabase(model: selectedCity)
            self.savedCityCollectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController {
    func setupAQIComment(aqi: Int) {
        aqiCommentLabel.animateWith(text: getAQIColorAndText(aqi: aqi).comment)
        aqiCommentLabel.textColor = getAQIColorAndText(aqi: aqi).color
    }
}

extension ViewController {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        guard let collectionView = savedCityCollectionView else { return }
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Changing the cell order, moving: \(sourceIndexPath.row) to \(destinationIndexPath.row)")
    }
} 
