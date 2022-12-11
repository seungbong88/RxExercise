//
//  ViewController.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/04.
//

import RxSwift
import RxCocoa

class MapViewController: UIViewController {
  
  @IBOutlet weak var habitatTableView: UITableView!
  
  let HabitateListURL = "https://pokeapi.co/api/v2/pokemon-habitat"  // 포켓몬 서식지 API
  
  var disposeBag = DisposeBag()
  var rxHabitatList = PublishSubject<[HabitatInfo]>()
  var rxHabitat = PublishSubject<PokeHabitat>()
  var rxSpecies = PublishSubject<PokeSpecies>()
  
  lazy var indicator: UIActivityIndicatorView = {
    let indicatorView = UIActivityIndicatorView()
    indicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    indicatorView.center = self.view.center
    return indicatorView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initUI()
    bindUI()
  }
  
  private func initUI() {
    self.view.addSubview(indicator)
  }
  
  private func bindUI() {
    rxHabitatList
      .observe(on: MainScheduler.instance)
      .bind(to: habitatTableView.rx.items(cellIdentifier: "cell",
                                          cellType: UITableViewCell.self)) { (row, element, cell) in
        cell.textLabel?.text = self.transferMapName(englishName: element.name)
      }
      .disposed(by: disposeBag)
    
    habitatTableView.rx.modelSelected(HabitatInfo.self)
      .subscribe(onNext: { habitat in
        let selectedHabitatUrl = habitat.url
        self.rxFetchHabitat(urlString: selectedHabitatUrl)
      })
      .disposed(by: disposeBag)
    
    rxHabitat
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: {
        self.rxFetchRandomSpecies(from: $0)
      }, onError: {
        print($0.localizedDescription)
      })
      .disposed(by: disposeBag)
    
    rxSpecies
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { sepecies in
        self.moveToField(with: sepecies)
      })
      .disposed(by: disposeBag)
  }
  
  private func moveToField(with pokemon: PokeSpecies) {
    DispatchQueue.main.async {
      let id = FieldViewController.id
      if let fieldVC = self.storyboard?.instantiateViewController(withIdentifier: id) as? FieldViewController {
        fieldVC.pokeSpecies = pokemon
        fieldVC.modalPresentationStyle = .fullScreen
        self.present(fieldVC, animated: true)
      }
    }
  }
  
  private func showLoading() {
    DispatchQueue.main.async {
      self.indicator.startAnimating()
    }
  }
  
  private func hideLoading() {
    DispatchQueue.main.async {
      self.indicator.stopAnimating()
    }
  }
  
  private func transferMapName(englishName: String) -> String {
    switch englishName {
    case "cave": return "동굴"
    case "forest": return "숲"
    case "grassland": return "목초지"
    case "waters-edge": return "물가"
    case "sea": return "바다"
    case "rough-terrain": return "거친 대지"
    case "rare": return "레어"
    case "mountain": return "산지"
    case "urban": return "도시"
    default: return englishName
    }
  }
  
  
  // MARK: - IBAction
  @IBAction func habitatLoadButtonDIdTap(_ sender: Any) {
    rxFetchHabitatList()
  }
  
  // MARK: - Fetch Data
  
  /// PublishSubject 을 이용한 data fetch
  /// - 미리 선언한 Subject 객체에 바로 onNext 이벤트를 보내줄 수 있다.
  private func rxFetchHabitatList() {
    guard let url = URL(string: HabitateListURL) else {
      self.rxHabitatList.onError(NetworkError.invalidUrl)
      return
    }
    
    showLoading()
    
    URLSession.shared.rx.data(request: URLRequest(url: url))
      .subscribe(onNext: { data in
        if let habitat = try? JSONDecoder().decode(TotalHabitat.self, from: data) {
          self.rxHabitatList.onNext(habitat.results ?? [])
        }
      }, onCompleted: {
        self.hideLoading()
      })
  }
  
  private func rxFetchHabitat(urlString: String) {
    guard let url = URL(string: urlString) else {
      rxHabitat.onError(NetworkError.invalidUrl)
      return
    }
    
    URLSession.shared.rx.data(request: URLRequest(url: url))
      .subscribe(onNext: { data in
        if let json = try? JSONDecoder().decode(PokeHabitat.Response.self, from: data) {
          self.rxHabitat.onNext(PokeHabitat(json: json))
        } else {
          self.rxHabitat.onError(NetworkError.failParsing)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func rxFetchRandomSpecies(from habitat: PokeHabitat) {
    let random = Int.random(in: 0..<habitat.speciesInfoList.count)
    let randomUrl = habitat.speciesInfoList[random].url
    
    guard let url = URL(string: randomUrl) else {
      rxSpecies.onError(NetworkError.invalidUrl)
      return
    }
    
    URLSession.shared.rx.data(request: URLRequest(url: url))
      .subscribe(onNext: { data in
        if let json = try? JSONDecoder().decode(PokeSpecies.Response.self, from: data) {
          self.rxSpecies.onNext(PokeSpecies(json: json))
        } else {
          self.rxSpecies.onError(NetworkError.failParsing)
        }
      })
      .disposed(by: disposeBag)
  }
}
