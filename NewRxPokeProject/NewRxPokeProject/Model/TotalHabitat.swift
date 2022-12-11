//
//  TotalHabitat.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/04.
//

import Foundation

/// 포켓몬 서식지 리스트 
struct TotalHabitat: Decodable {
    var results: [HabitatInfo]?
}

struct HabitatInfo: Decodable {
    var name: String
    var url: String
}
