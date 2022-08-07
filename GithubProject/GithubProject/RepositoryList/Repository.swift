//
//  Repository.swift
//  GithubProject
//
//  Created by SeungHee Han on 2022/08/07.
//

import Foundation

struct Repository: Decodable {
    let id: Int
    let name: String
    let description: String
    let stargazersCount: Int
    let language: String
    
    enum CodingKey: String, CodingKey {
        case id, name, description, language
        case stargazersCount = "stargazers_count"
    }
}

