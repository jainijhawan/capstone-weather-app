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
    
    func setupUI(segmentControlIndex: Int) {
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 8
        tempratureLabel.text = "11"
        
        if segmentControlIndex == 0 {
            changeUIForCelcius()
        } else {
            changeUIForFar()
        }
    }
    
    func changeUIForCelcius() {
        tempratureLabel.text = tempInCelcius(text: tempratureLabel.text)
        metricLabel.text = "°C"
    }
    
    func changeUIForFar() {
        tempratureLabel.text = tempInFahrenheit(text: tempratureLabel.text)
        metricLabel.text = "°F"
    }
}
