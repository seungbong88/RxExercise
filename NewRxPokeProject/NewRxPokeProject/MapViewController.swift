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
  
  let habitateURL = "https://pokeapi.co/api/v2/pokemon-habitat"  // 포켓몬 서식지 API
  
  var rxHabitat = PublishSubject<[HabitatInfo]>()
  var disposeBag = DisposeBag()
  
  enum NetworkError: Error {
    case invalidUrl
    case failParsing
  }
  
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
    rxHabitat
      .observe(on: MainScheduler.instance)
      .bind(to: habitatTableView.rx.items(cellIdentifier: "cell",
                                          cellType: UITableViewCell.self)) { (row, element, cell) in
        cell.textLabel?.text = self.transferMapName(englishName: element.name)
      }
      .disposed(by: disposeBag)
    
    habitatTableView.rx.itemSelected
      .subscribe(onNext: { indexPath in
        print("\(indexPath.row) >> 눌렸삼요")
      })
      .disposed(by: disposeBag)
  }
  
  
  /// PublishSubject 을 이용한 data fetch -> 미리 선언한 Subject 객체에 바로 onNext 이벤트를 보내줄 수 있다.
  private func rxFetchHabitatWithSubject() {
    
    guard let url = URL(string: habitateURL) else {
      self.rxHabitat.onError(NetworkError.invalidUrl)
      return
    }
    
    showLoading()
    
    let request = URLRequest(url: url)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      sleep(2)
      if let error = error {
        self.rxHabitat.onError(error)
        return
      }
      
      if let habitat = try? JSONDecoder().decode(TotalHabitat.self, from: data!) {
        self.rxHabitat.onNext(habitat.results ?? [])
      }
      
      self.rxHabitat.onCompleted()
    }
    .resume()
  }
  
  
  @IBAction func habitatLoadButtonDIdTap(_ sender: Any) {
    rxFetchHabitatWithSubject()
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
}
