//
//  AQIDataModel.swift
//  Weather App
//
//  Created by Rajat Kumar on 2023-10-22.
//

import Foundation

// MARK: - AQIDataModel
struct AQIDataModel: Codable {
    let overallAqi: Int?
    let co, pm10, so2, pm25: Co?
    let o3, no2: Co?

    enum CodingKeys: String, CodingKey {
        case overallAqi = "overall_aqi"
        case co = "CO"
        case pm10 = "PM10"
        case so2 = "SO2"
        case pm25 = "PM2.5"
        case o3 = "O3"
        case no2 = "NO2"
    }
}

// MARK: - Co
struct Co: Codable {
    let concentration: Double?
    let aqi: Int?
}
