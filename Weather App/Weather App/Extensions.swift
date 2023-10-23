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
