//
//  CityNameSuggestionModel.swift
//  Weather App
//
//  Created by Nevil james on 2023-11-02.
//

import UIKit

// MARK: - CityNameSuggestionModel
struct CityNameSuggestionModel: Codable {
    let results: [Result]?
    let query: Query?
}

// MARK: - Query
struct Query: Codable {
    let text: String?
    let parsed: Parsed?
}

// MARK: - Parsed
struct Parsed: Codable {
    let city, expectedType: String?

    enum CodingKeys: String, CodingKey {
        case city
        case expectedType = "expected_type"
    }
}

// MARK: - Result
struct Result: Codable {
    let datasource: Datasource?
    let country, countryCode, state, county: String?
    let city: String?
    let lon, lat: Double?
    let stateCode, formatted, addressLine1, addressLine2: String?
    let category: String?
    let timezone: Timezone?
    let plusCode, plusCodeShort, resultType: String?
    let rank: Rank?
    let placeID: String?
    let bbox: Bbox?

    enum CodingKeys: String, CodingKey {
        case datasource, country
        case countryCode = "country_code"
        case state, county, city, lon, lat
        case stateCode = "state_code"
        case formatted
        case addressLine1 = "address_line1"
        case addressLine2 = "address_line2"
        case category, timezone
        case plusCode = "plus_code"
        case plusCodeShort = "plus_code_short"
        case resultType = "result_type"
        case rank
        case placeID = "place_id"
        case bbox
    }
}

// MARK: - Bbox
struct Bbox: Codable {
    let lon1, lat1, lon2, lat2: Double?
}

// MARK: - Datasource
struct Datasource: Codable {
    let sourcename, attribution, license: String?
    let url: String?
}

// MARK: - Rank
struct Rank: Codable {
    let importance: Double?
    let confidence, confidenceCityLevel: Int?
    let matchType: String?

    enum CodingKeys: String, CodingKey {
        case importance, confidence
        case confidenceCityLevel = "confidence_city_level"
        case matchType = "match_type"
    }
}

// MARK: - Timezone
struct Timezone: Codable {
    let name, offsetSTD: String?
    let offsetSTDSeconds: Int?
    let offsetDST: String?
    let offsetDSTSeconds: Int?
    let abbreviationSTD, abbreviationDST: String?

    enum CodingKeys: String, CodingKey {
        case name
        case offsetSTD = "offset_STD"
        case offsetSTDSeconds = "offset_STD_seconds"
        case offsetDST = "offset_DST"
        case offsetDSTSeconds = "offset_DST_seconds"
        case abbreviationSTD = "abbreviation_STD"
        case abbreviationDST = "abbreviation_DST"
    }
}

struct SavedCityModel: Codable {
    var name: String
    var lat: Double
    var lon: Double
    var temp: Double
    var aqi: Int = 0
    var tagColor: String
    var tagText: String
}
