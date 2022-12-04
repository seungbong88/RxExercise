//
//  TotalHabitat.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/04.
//

import Foundation

struct TotalHabitat: Decodable {
    var results: [HabitatInfo]?
}

struct HabitatInfo: Decodable {
    var name: String
    var url: String
}
