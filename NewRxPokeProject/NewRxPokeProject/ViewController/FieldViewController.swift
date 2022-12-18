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
  @IBOutlet weak var goBackButton: UIButton!
  
  static let id = "FieldViewController"
  let pokemonUrl = "https://pokeapi.co/api/v2/pokemon/"          // 포켓몬 API
  
  var pokeSpecies: PokeSpecies?
  let rxPokemonSubject = BehaviorSubject<Pokemon>(value: Pokemon())
  let rxCatchResult =  PublishSubject<CatchResult>()
  
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchPokemon()
    bindUI()
    initUI()
  }
  
  private func initUI() {
    rxCatchResult.onNext(.didNotAppear) // 초기값
    
    pokeImageView.translatesAutoresizingMaskIntoConstraints = true
    pokeImageView.frame.origin = CGPoint(x: 0 - pokeImageView.frame.size.width,
                                         y: pokeImageView.frame.origin.y)
    
    self.catchButton.isEnabled = false
  }
  
  private func bindUI() {
    rxPokemonSubject
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        
        self.pokeImageView.image = self.loadImage(from: $0.sprites?.front_default)
        self.fieldTopText.text = "\(self.pokeSpecies?.name ?? "??")이(가) 나타났다!"
        self.appearPokemonImageView()
      })
      .disposed(by: disposeBag)
    
    catchButton
      .rx.tap.subscribe(onNext: {
        self.rxCatchResult.onNext(self.getCatchResult())
      })
      .disposed(by: disposeBag)
    
    rxCatchResult
      .subscribe(onNext: {
        self.updateView(with: $0)
      })
      .disposed(by: disposeBag)
    
    rxCatchResult
      .delay(.seconds(3), scheduler: MainScheduler.instance)
      .subscribe(onNext: {
        if $0 == .runAway || $0 == .captured {
          self.dismiss(animated: true)
        }
      })
      .disposed(by: disposeBag)
    
    goBackButton
      .rx.tap.bind {
        self.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  private func fetchPokemon() {
    guard let species = pokeSpecies,
          let url = URL(string: pokemonUrl + "\(species.id)") else {
      rxPokemonSubject.onError(NetworkError.invalidUrl)
      return
    }
    
    URLSession.shared.rx.data(request: URLRequest(url: url))
      .subscribe(onNext: { data in
        if let json = try? JSONDecoder().decode(Pokemon.Response.self, from: data) {
          self.rxPokemonSubject.onNext(Pokemon(json: json))
        } else {
          self.rxPokemonSubject.onError(NetworkError.failParsing)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func getCatchResult() -> CatchResult {
    let difficulty = 0.3
    let captureRate: Int = pokeSpecies?.captureRate ?? 0
    let runAwayRate: Int = Int(Double(255 - captureRate) * difficulty)
    let random = Int.random(in: 0...255)
    print("랜덤값 : \(random) / 포획률:  \(captureRate) / 도망갈 확률: \(runAwayRate)")
    
    if random <= captureRate {
      return .captured
    } else if random <= runAwayRate {
      return .runAway
    } else {
      return .miss
    }
  }
  
  private func appearPokemonImageView() {
    UIView.animate(withDuration: 2, animations: { [weak self] in
      guard let self = self else { return }
      self.pokeImageView.frame.origin = CGPoint(x: (self.view.frame.size.width - self.pokeImageView.frame.width) / 2,
                                                y: self.pokeImageView.frame.origin.y)
      self.pokeImageView.startRotate()
      self.catchButton.isEnabled = false
    }, completion: { _ in
      self.pokeImageView.stopRotate()
      self.catchButton.isEnabled = true
    })
  }
  
  private func disappearPokemonImageView() {
    UIView.animate(withDuration: 2, animations: { [weak self] in
      guard let self = self else { return }
      self.pokeImageView.frame.origin = CGPoint(x: self.view.frame.size.width,
                                                y: self.pokeImageView.frame.origin.y)
      self.pokeImageView.startRotate()
      self.catchButton.isEnabled = false
    }, completion: { _ in
      self.pokeImageView.stopRotate()
      self.dismiss(animated: true)
    })
  }
  
  private func updateView(with catchResult: CatchResult) {
    fieldBottomText.text = "\(self.pokeSpecies?.name ?? "??" )" + catchResult.description
    fieldBottomText.textColor = catchResult.textColor
    fieldBottomText.isHidden = false
    
    rxPokemonSubject
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] pokemon in
        guard let self = self else { return }
        
        switch catchResult {
        case .didNotAppear:
          self.fieldBottomText.isHidden = true
        case .captured:
          self.pokeImageView.image = self.loadImage(from: pokemon.sprites?.front_shiny)
          self.catchButton.isEnabled = false
        case .runAway:
          self.pokeImageView.image = self.loadImage(from: pokemon.sprites?.back_default)
          self.disappearPokemonImageView()
        case .miss:
          break
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func loadImage(from imageUrl: String?) -> UIImage? {
    if let url = URL(string: imageUrl ?? ""),
       let imageData = try? Data(contentsOf: url) {
      return UIImage(data: imageData)
    }
    
    return nil
  }
}

enum CatchResult {
  case didNotAppear
  case captured
  case miss
  case runAway
  
  var description: String {
    switch self {
    case .didNotAppear: return ""
    case .captured:     return "을(를) 잡았다!"
    case .miss:         return "이(가) 잡히지 않았다."
    case .runAway:      return "이(가) 도망갔다."
    }
  }
  
  var textColor: UIColor {
    switch self {
    case .didNotAppear: return .black
    case .captured:     return .orange
    case .miss:         return .black
    case .runAway:      return .cyan
    }
  }
}
