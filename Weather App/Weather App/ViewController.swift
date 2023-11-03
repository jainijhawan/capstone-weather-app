//
//  ViewController.swift
//  Weather App
//
//  Created by Jai Nijhawan on 01/10/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var metricSegmentControl: UISegmentedControl!
    @IBOutlet weak var savedCityCollectionView: UICollectionView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        setDefaultVAlues()
        savedCityCollectionView.delegate = self
        savedCityCollectionView.dataSource = self
        savedCityCollectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        reloadCityList()

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
    }
    
    @IBAction func searchTapped(_ sender: Any) {
        
    }
}

extension ViewController: UICollectionViewDelegate,
                            UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        cityDataDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:SavedCityCollectionViewCell.self), for: indexPath) as? SavedCityCollectionViewCell else {
            return UICollectionViewCell()
        }
        let city = cityDataDataSource[indexPath.row]
        cell.setupUI(segmentControlIndex: metricSegmentControl.selectedSegmentIndex, cityName: city.name, temp: city.temp)
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined,
                .restricted,
                .denied:
            break
            
        case .authorizedAlways,
                .authorizedWhenInUse,
                .authorized:
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
        currentTempratureLabel.animateWith(text: data.main?.temp?.getTempInCelcius() ?? "")
        currentDayLabel.animateWith(text: Date().dayOfWeek() ?? "")
        currentDateLabel.animateWith(text: Date().getCurrentDate())
        metricLabel.animateWith(text: "°C")
        maximumTempLabel.animateWith(text: (data.main?.tempMax?.getTempInCelcius() ?? "") + "°C")
        minimumTempLabel.animateWith(text: (data.main?.tempMin?.getTempInCelcius() ?? "") + "°C")
        cityNameLabel.animateWith(text: data.name ?? "")
        weatherConditionLabel.animateWith(text: data.weather?.first?.description?.capitalized ?? "")
    }
    
    func setupUIforAQI(data: AQIDataModel) {
        guard let aqi = data.list.first?.main.aqi else { return }
        aqiLabel.text = "AQI: \(aqi)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.transition(with: self.backgroundAQIImageView,
                              duration: 4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.backgroundAQIImageView.image = getAQIColorTextAndBG(aqi: Int(aqi)).image
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
