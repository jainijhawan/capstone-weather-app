//
//  SavedCityCollectionViewCell.swift
//  Weather App
//
//  Created by Jai Nijhawan on 02/11/23.
//

import UIKit

class SavedCityCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var metricLabel: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagView: UIView!
    
    func setupUI(segmentControlIndex: Int, cityName: String, temp: Double, tagColor: UIColor, tagText: String) {
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 8
        tagView.layer.cornerRadius = 4
        cityNameLabel.text = cityName
        if segmentControlIndex == 0 {
            changeUIForCelcius(temp: temp)
        } else {
            changeUIForFar(temp: temp)
        }
        
        if tagColor == .clear {
            tagView.isHidden = true
            tagLabel.text = ""
        } else {
            tagView.isHidden = false
            tagLabel.text = tagText
            tagView.backgroundColor = tagColor.withAlphaComponent(0.4)
        }
    }
    
    func changeUIForCelcius(temp: Double) {
        tempratureLabel.text = temp.getTempInCelcius()
        metricLabel.text = "°C"
    }
    
    func changeUIForFar(temp: Double) {
        tempratureLabel.text = tempInFahrenheit(text: temp.getTempInCelcius())
        metricLabel.text = "°F"
    }
    
    func setupAQI(aqi: Int) {
        aqiLabel.text = "AQI: \(aqi)"
    }
}
