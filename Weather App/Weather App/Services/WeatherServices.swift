//
//  WeatherServices.swift
//  Weather App
//
//  Created by Tushar Sharma on 2023-10-22.
//

import Foundation

class WeatherServices {
    static let shared = WeatherServices()
    let APIKEY = "26f27d2f85c162f957c7478df0bcb6e0"
    
    private init() {
        
    }
    
    
    
    func getCurrentCityData(lat: Double,
                            lon: Double,
                            completion: @escaping (Bool, CurrentWeatherData?)->Void) {
        let myURL = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lon)&appid=\(APIKEY)"
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
           let myURL = "https://api.api-ninjas.com/v1/airquality?lat=\(lat)&lon=\(lon)"
           guard let urlString = URL(string: myURL) else {
               return
           }
        var request = URLRequest(url: urlString)
        request.setValue("H4yl144npI8ZXwnYIpCMZQ==pEgri5E2wuMndHSO", forHTTPHeaderField: "X-Api-Key")
        
           URLSession.shared.dataTask(with: request) { data, response, error in
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
    
    func getCityNames(searchText: String, completion: @escaping (Bool, CityNameSuggestionModel?) -> Void) {
        let apiKey = "7d99448845094d1d8bbfff8338f7eaa2"
        let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let myUrl = "https://api.geoapify.com/v1/geocode/autocomplete?text=\(encodedSearchText)&type=city&format=json&apiKey=\(apiKey)"
        
        guard let urlString = URL(string: myUrl) else {
            return
        }
        
        URLSession.shared.dataTask(with: urlString) { data, response, error in
            if let data = data {
                if let weatherData = try? JSONDecoder().decode(CityNameSuggestionModel.self, from: data) {
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
