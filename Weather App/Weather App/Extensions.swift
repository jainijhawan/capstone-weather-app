//
//  Extensions.swift
//  Weather App
//
//  Created by Harwinderjit Kaur on 2023-10-22.
//

import UIKit

extension Double {
  func getTempInCelcius() -> String {
    return String(format: "%.0f", self - 273.15)
  }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    func getCurrentDate() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM d, yyyy"
        let result = dateFormatterPrint.string(from: self)
        return result
    }
}

extension UILabel {
    func animateWith(text: String, duration: Double = 1.2) {
        UIView.transition(with: self,
                          duration: duration,
                          options: .transitionFlipFromBottom,
                          animations: { [weak self] in
            self?.text = text
        }, completion: nil)
    }
}

func getAQIColorTextAndBG(aqi: Int) -> (color: UIColor, comment:String, image: UIImage?) {
  var rgb: (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
  var comment = ""
    var bg: UIImage? = UIImage()
  switch aqi {
  case 0...50:
    rgb = (1, 152, 102)
    comment = "It's Good !"
    bg = UIImage(named: "bg1")
  case 51...100:
    rgb = (255, 215, 0)
    comment = "It's Moderate !"
      bg = UIImage(named: "bg1")
  case 101...150:
    rgb = (255, 153, 51)
    comment = "It's Unhealthy !"
      bg = UIImage(named: "bg2")
  case 151...200:
    rgb = (247, 0, 1)
    comment = "Still Unhealthy !"
      bg = UIImage(named: "bg3")
  case 201...300:
    rgb = (102, 0, 153)
    comment = "Very Unhealthy !"
      bg = UIImage(named: "bg4")
  case 300...999:
    rgb = (126, 0, 35)
    comment = "It's Hazardous !"
      bg = UIImage(named: "bg5")
  default:
    rgb = (0, 0, 0)
  }
  return (UIColor(red: rgb.0/255,
                  green: rgb.1/255,
                  blue: rgb.2/255,
                  alpha: 1.0),
          comment,
          bg)
}

func calculateCelsius(fahrenheit: Double) -> Double {
    var celsius: Double
    celsius = (fahrenheit - 32) * 5 / 9
    return celsius
}

func calculateFahrenheit(celsius: Double) -> Double {
    var fahrenheit: Double
    fahrenheit = celsius * 9 / 5 + 32
    return fahrenheit
}

func tempInFahrenheit(text: String?) -> String {
  if let temp = Double(text!) {
    let tempFar = calculateFahrenheit(celsius: temp)
    let x = String(format: "%.0f", tempFar)
    return x + ""
  } else {
    return ""
  }
}

func tempInCelcius(text: String?) -> String {
  if let temp = Double(text!) {
    let tempFar = calculateCelsius(fahrenheit: temp)
    let x = String(format: "%.0f", tempFar)
    return x
  } else {
    return ""
  }
}

func saveCityToDataBase(model: SavedCityModel) {
    let userDefaults = UserDefaults.standard

    if let savedCitiesData: Data = userDefaults.object(forKey: "savedCityList") as? Data {
        
        do {
            let decoder = JSONDecoder()
            var myData = try decoder.decode([SavedCityModel].self, from: savedCitiesData)
            myData.append(model)
            do {
                let data = try JSONEncoder().encode(myData)
                UserDefaults.standard.set(data, forKey: "savedCityList")
            } catch {
                // Fallback
            }
        } catch {
            // Fallback
        }
        
    } else {
        do {
            let data = try JSONEncoder().encode([model])
            UserDefaults.standard.set(data, forKey: "savedCityList")
        } catch {
            // Fallback
        }
    }

}

func getSavedCities() -> [SavedCityModel] {
    guard let data = UserDefaults.standard.data(forKey: "savedCityList") else {
        return []
    }
    do {
        let decoder = JSONDecoder()
        let myData = try decoder.decode([SavedCityModel].self, from: data)
        return myData
    } catch {
        // Fallback
    }
    return []
}
