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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        setDefaultVAlues()
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
