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
  
  @IBOutlet weak var fieldTopText: UILabel!
  @IBOutlet weak var pokeImageView: UIImageView!
  @IBOutlet weak var fieldBottomText: UILabel!
  @IBOutlet weak var catchButton: UIButton!
  
  static let id = "FieldViewController"
  let pokemonUrl = "https://pokeapi.co/api/v2/pokemon/"          // 포켓몬 API
  
  var pokeSpecies: PokeSpecies?
  var pokemon = PublishSubject<Pokemon>()
  let catchResult =  PublishSubject<CatchResult>()
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
    
    catchButton.rx.tap
      .subscribe(onNext: {
        self.catchResult.onNext(self.getCatchResult())
      })
      .disposed(by: disposeBag)
    
    catchResult
      .subscribe(onNext: { [weak self] result in
        guard let self = self else { return }
        self.fieldBottomText.text = result.description
        self.fieldBottomText.textColor = result.textColor
      })
      .disposed(by: disposeBag)
    
    catchResult
      .delay(.seconds(2), scheduler: MainScheduler.instance)
      .subscribe(onNext: {
        if $0 == .runAway || $0 == .captured {
          self.dismiss(animated: true)
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
  
  private func getCatchResult() -> CatchResult {
    let captureRate: Int = pokeSpecies?.captureRate ?? 0
    let runAwayRate: Int = Int(Double(255 - captureRate) * 0.3)
    let random = Int.random(in: 0...255)
    print("\(random) / \(captureRate) / \(runAwayRate)")
    
    if random <= captureRate {
      return .captured
    } else if random <= runAwayRate {
      return .runAway
    } else {
      return .miss
    }
  }
}

enum CatchResult {
  case captured
  case miss
  case runAway
  
  var description: String {
    switch self {
    case .captured: return "을(를) 잡았다!"
    case .miss:     return "이(가) 잡히지 않았다."
    case .runAway:  return "이(가) 도망갔다."
    }
  }
  
  var textColor: UIColor {
    switch self {
    case .captured: return .orange
    case .miss:     return .black
    case .runAway:  return .cyan
    }
  }
}
