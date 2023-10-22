//
//  AQIDataModel.swift
//  Weather App
//
//  Created by Rajat Kumar on 2023-10-22.
//

import Foundation

// MARK: - AQIDataModel
struct AQIDataModel: Codable {
    let coord: Coord
    let list: [List]
}

// MARK: - List
struct List: Codable {
    let main: Main
    let components: [String: Double]
    let dt: Int
}

