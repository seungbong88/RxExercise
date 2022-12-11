//
//  FieldViewController.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/11.
//

import UIKit
import RxSwift
import RxCocoa

class FieldViewController: UIViewController {
    
    @IBOutlet weak var pokeImageView: UIImageView!
    @IBOutlet weak var fieldTopText: UILabel!
    @IBOutlet weak var fieldBottomText: UILabel!
    
    static let id = "FieldViewController"
    let pokemonUrl = "https://pokeapi.co/api/v2/pokemon/"          // 포켓몬 API
    
    var pokeSpecies: PokeSpecies?
    var pokemon = PublishSubject<Pokemon>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPokemon()
        bindUI()
    }
    
    private func bindUI() {
        pokemon
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                if let imageUrl = $0.sprites?.front_default,
                   let url = URL(string: imageUrl),
                   let imageData = try? Data(contentsOf: url) {
                    self.pokeImageView.image = UIImage(data: imageData)
                    self.fieldTopText.text = "\($0.name)이(가) 나타났다!"
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchPokemon() {
        guard let species = pokeSpecies,
              let url = URL(string: pokemonUrl + "\(species.id)") else {
            pokemon.onError(NetworkError.invalidUrl)
            return
        }
        
        URLSession.shared.rx.data(request: URLRequest(url: url))
            .subscribe(onNext: { data in
                if let json = try? JSONDecoder().decode(Pokemon.Response.self, from: data) {
                    self.pokemon.onNext(Pokemon(json: json))
                } else {
                    self.pokemon.onError(NetworkError.failParsing)
                }
            })
            .disposed(by: disposeBag)
    }
    @IBAction func catchButtonDidTap(_ sender: Any) {
        
    }
}
