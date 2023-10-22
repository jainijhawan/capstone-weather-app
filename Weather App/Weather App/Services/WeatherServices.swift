//
//  WeatherServices.swift
//  Weather App
//
//  Created by Tushar Sharma on 2023-10-22.
//

import Foundation

class WeatherServices {
    static let shared = WeatherServices()
    let APIKEY = "90b7863a4aa0bbbdd4627d683db1db78"
    
    private init() {
        
    }
    
    
    
    func getCurrentCityData(lat: Double,
                            lon: Double,
                            completion: @escaping (Bool, CurrentWeatherData?)->Void) {
        let myURL = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(APIKEY)"
        guard let urlString = URL(string: myURL) else {
            return
        }
        URLSession.shared.dataTask(with: URLRequest(url: urlString)) { data, response, error in
            if let data = data {
                if let weatherData = try? JSONDecoder().decode(CurrentWeatherData.self, from: data) {
                    completion(true, weatherData)
                } else {
                    print("Invalid Response")
                    completion(false, nil)
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                completion(false, nil)
            }
        }.resume()
    }
    
    func getCurrentLocationAQI(lat: Double,
                               lon: Double,
                               completion: @escaping (Bool, AQIDataModel?)->Void) {
           let myURL = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(lat)&lon=\(lon)&appid=\(APIKEY)"
           guard let urlString = URL(string: myURL) else {
               return
           }
           URLSession.shared.dataTask(with: URLRequest(url: urlString)) { data, response, error in
               if let data = data {
                   if let weatherData = try? JSONDecoder().decode(AQIDataModel.self, from: data) {
                       completion(true, weatherData)
                   } else {
                       print("Invalid Response")
                       completion(false, nil)
                   }
               } else if let error = error {
                   print("HTTP Request Failed \(error)")
                   completion(false, nil)
               }
           }.resume()
       }
}
