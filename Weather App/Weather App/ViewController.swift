//
//  ViewController.swift
//  Weather App
//
//  Created by Jai Nijhawan on 01/10/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    
    @IBOutlet weak var minimumTempLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var currentDayLabel: UILabel!
    @IBOutlet weak var maximumTempLabel: UILabel!
    @IBOutlet weak var metricLabel: UILabel!
    @IBOutlet weak var currentTempratureLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    var locationManager: CLLocationManager?
    let weatherService = WeatherServices.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func requestWeatherFor(lat: Double, lon: Double) {
        weatherService.getCurrentCityData(lat: lat, lon: lon) { isSuccess, weatherData in
            if isSuccess {
                print(weatherData)
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
                print(AQIData)
                DispatchQueue.main.async {
                    self.aqiLabel.text = "AQI: \(AQIData?.list.first?.main.aqi ?? 0)"
                }
            }
        }
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
        currentTempratureLabel.text = data.main?.temp?.getTempInCelcius() ?? ""
        currentDayLabel.text = Date().dayOfWeek()
        currentDateLabel.text = Date().getCurrentDate()
        metricLabel.text = "°C"
        maximumTempLabel.text = (data.main?.tempMax?.getTempInCelcius() ?? "") + "°C"
        minimumTempLabel.text = (data.main?.tempMin?.getTempInCelcius() ?? "") + "°C"
        cityNameLabel.text = data.name ?? ""
        weatherConditionLabel.text = data.weather?.first?.description?.capitalized ?? ""
    }
}
