//
//  HourlyWeatherCollectionViewCell.swift
//  Weather App
//
//  Created by Jai Nijhawan on 11/11/23.
//

import UIKit

struct HourlyWeatherCollectionViewCellModel {
  let time: String
  let id: Int
  let temprature: String
  let index: Int
    let tempDouble: Double
}

class HourlyWeatherCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var nextDayView: UIView!
    @IBOutlet weak var dataStackView: UIStackView!
    
    func setupUI(time: String, id: Int, temprature: String, index: Int) {
        weatherImageView.image = getPNGFromCurrentWeatherID(id: id)
        tempratureLabel.text = temprature
        timeLabel.text = time
    }
    
    var viewModel: HourlyWeatherCollectionViewCellModel? {
      didSet {
        if viewModel?.index == 0 {
          timeLabel.text = "NOW"
        } else {
          timeLabel.text = viewModel?.time
        }
          weatherImageView.image = getPNGFromCurrentWeatherID(id: viewModel!.id)
        tempratureLabel.text = viewModel?.temprature
        if viewModel?.id == 0 {
          nextDayView.alpha = 1
          dataStackView.alpha = 0
        } else {
          nextDayView.alpha = 0
          dataStackView.alpha = 1
        }
          dataStackView.spacing = 10
          contentView.layoutIfNeeded()
      }
    }
    
    func changeUIForCelcius(temp: Double) {
        tempratureLabel.text = temp.getTempInCelcius() + "°C"
    }
    
    func changeUIForFar(temp: Double) {
        tempratureLabel.text = tempInFahrenheit(text: temp.getTempInCelcius()) + "°F"
    }
    func setupUI(viewModel: HourlyWeatherCollectionViewCellModel, segmentControlIndex: Int) {
        if viewModel.index == 0 {
          timeLabel.text = "NOW"
        } else {
          timeLabel.text = viewModel.time
        }
          weatherImageView.image = getPNGFromCurrentWeatherID(id: viewModel.id)
        tempratureLabel.text = viewModel.temprature
        if viewModel.id == 0 {
          nextDayView.alpha = 1
          dataStackView.alpha = 0
        } else {
          nextDayView.alpha = 0
          dataStackView.alpha = 1
        }
          dataStackView.spacing = 10
          contentView.layoutIfNeeded()
        
        let temp = viewModel.tempDouble
        if segmentControlIndex == 0 {
            changeUIForCelcius(temp: temp)
        } else {
            changeUIForFar(temp: temp)
        }
    }
}
