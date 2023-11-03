//
//  SearchCityTableViewCell.swift
//  Weather App
//
//  Created by Nevil james on 2023-11-02.
//

import UIKit

class SearchCityTableViewCell: UITableViewCell {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    func setupUI(cityNameText: String) {
        bgView.layer.borderColor = UIColor.white.cgColor
        bgView.layer.borderWidth = 2
        bgView.layer.cornerRadius = 8
        cityName.text = cityNameText
    }
}

