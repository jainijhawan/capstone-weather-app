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
    
    func setupUI() {
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 8
    }
    
}
