//
//  UserDefaultsManager.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/18.
//

import Foundation

class UserDefaultsManager {
  
  static let shared = UserDefaultsManager()
  
  enum UserDefaultsKey: String {
    case pokedex
  }
  
  func save(data: Any, key: String) {
    UserDefaults.standard.set(data, forKey: key)
  }
}
