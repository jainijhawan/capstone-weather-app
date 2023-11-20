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

func getAQIBG(aqi: Int) -> UIImage? {
    var bg: UIImage? = UIImage()
  switch aqi {
  case 0...50:
    bg = UIImage(named: "bg1")
  case 51...100:
      bg = UIImage(named: "bg1")
  case 101...150:
      bg = UIImage(named: "bg2")
  case 151...200:
      bg = UIImage(named: "bg3")
  case 201...300:
      bg = UIImage(named: "bg4")
  case 300...999:
      bg = UIImage(named: "bg5")
  default:
    bg = nil
  }
  return bg
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

func getPNGFromCurrentWeatherID(id: Int) -> UIImage? {
    var name = ""
    switch id {
    case 200...202:
      name = "Thunderstorm + Rain"
    case 210...221:
      name = "Thunderstorm"
    case 230...232:
      name = "Thunderstorm + Rain"
    case 300...599:
      name = "Rain"
    case 600...601:
      name = "Snow"
    case 611...622:
      name = "Rain Heavy"
    case 700...799:
      name = "Mist"
    case 800:
      name = "Sun"
    case 801:
      name = "Cloud"
    case 802...899:
      name = "Sun + Cloud"
    default:
      name = "Sun.gif"
    }
    return UIImage(named: name)
  }

func removeCityFromDatabase(model: SavedCityModel) {
    let userDefaults = UserDefaults.standard

    if let savedCitiesData: Data = userDefaults.object(forKey: "savedCityList") as? Data {
        do {
            let decoder = JSONDecoder()
            var myData = try decoder.decode([SavedCityModel].self, from: savedCitiesData)
            
            // Find the index of the city to remove based on latitude and longitude
            if let index = myData.firstIndex(where: { $0.lat == model.lat && $0.lon == model.lon }) {
                myData.remove(at: index)
                
                // Update UserDefaults with the modified data
                do {
                    let data = try JSONEncoder().encode(myData)
                    UserDefaults.standard.set(data, forKey: "savedCityList")
                } catch {
                    // Handle encoding error
                    print("Error encoding data: \(error.localizedDescription)")
                }
            }
        } catch {
            // Handle decoding error
            print("Error decoding data: \(error.localizedDescription)")
        }
    }
}

typealias CityData = (city: String,
                      country: String,
                      lat: String,
                      lon: String)

func getAQIColorAndText(aqi: Int) -> (color: UIColor, comment: String) {
  var rgb: (CGFloat, CGFloat, CGFloat) = (0, 0, 0)
  var comment = ""
  switch aqi {
  case 0...50:
    rgb = (1, 152, 102)
    comment = "It's Good !"
  case 51...100:
    rgb = (255, 215, 0)
    comment = "It's Moderate !"
  case 101...150:
    rgb = (255, 153, 51)
    comment = "It's Unhealthy !"
  case 151...200:
    rgb = (247, 0, 1)
    comment = "Still Unhealthy !"
  case 201...300:
    rgb = (102, 0, 153)
    comment = "Very Unhealthy !"
  case 300...999:
    rgb = (126, 0, 35)
    comment = "It's Hazardous !"
  default:
    rgb = (0, 0, 0)
  }
  return (color: UIColor(red: rgb.0/255, green: rgb.1/255, blue: rgb.2/255, alpha: 1.0), comment: comment)
}

extension UIColor {
    
    // MARK: - Initialization
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // MARK: - Computed Properties
    
    var toHex: String? {
        return toHex()
    }
    
    // MARK: - From UIColor to String
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
}
