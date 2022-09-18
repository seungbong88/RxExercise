//
//  Weather.swift
//  WeatherAppProject
//
//  Created by seungbong on 2022/09/05.
//

import Foundation

struct Weather: Decodable {
    let name: String
    let icon: String?
    let main: Main?

    struct Main: Decodable {
        let temp: Double?
        let humidity: Int?
    }
}
