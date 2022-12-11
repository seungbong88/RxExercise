//
//  FieldViewController.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/11.
//

import UIKit

class FieldViewController: UIViewController {
    static let id = "FieldViewController"
    
    var pokeSpecies: PokeSpecies?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(pokeSpecies)
    }
}
