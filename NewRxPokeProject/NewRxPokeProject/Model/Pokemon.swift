//
//  Pokemon.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/11.
//

import UIKit

struct Pokemon {
  var id: Int
  var name: String
  var species: SpaiesInfo?
  var sprites: SpriteInfo?
    
  var spriteImages: [UIImage] = []
  var pokeSpacies: PokeSpecies?
  
  init(json: Response) {
    self.id = json.id
    self.name = json.name
    self.species = json.species
    self.sprites = json.sprites
  }
  
  init() {
    self.id = 0
    self.name = ""
  }
}

// MARK: - Poke Species Property Types
extension Pokemon {
  struct Response: Codable {
    var id: Int
    var name: String
    var species: SpaiesInfo?
    var sprites: SpriteInfo?
  }
  
  struct SpaiesInfo: Codable {
    var name: String
    var url: String
  }
  
  struct SpriteInfo: Codable {
    var back_default: String?
    var back_shiny: String?
    var front_default: String?
    var front_shiny: String?
  }
}
