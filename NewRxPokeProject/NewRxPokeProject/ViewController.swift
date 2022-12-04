//
//  ViewController.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/04.
//

import RxSwift
import RxCocoa

class ViewController: UIViewController {
  
  @IBOutlet weak var habitatTableView: UITableView!
  
  let habitateURL = "https://pokeapi.co/api/v2/pokemon-habitat"  // 포켓몬 서식지 API
  
  var habitat: TotalHabitat?
  
  var rxHabitat = PublishSubject<TotalHabitat>()
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
    
    self.view.addSubview(indicator)
    
    habitatTableView.delegate = self
    habitatTableView.dataSource = self
    
    rxHabitat.subscribe(onNext: { habitat in
      self.habitat = habitat
      DispatchQueue.main.async {
        self.habitatTableView.reloadData()
      }
      
    }, onError: { error in
      self.hideLoading()
      print("\(error.localizedDescription)")
    }, onCompleted: {
      self.hideLoading()
    })
    .disposed(by: disposeBag)
  }
  
  private func bindUI() {
    
  }
  
  private func fetchHabitat() {
    let url = URL(string: habitateURL)!
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      if let habitat = try? JSONDecoder().decode(TotalHabitat.self, from: data!) {
        self.habitat = habitat
        print(habitat)
        DispatchQueue.main.async {
          self.habitatTableView.reloadData()
        }
      } else {
        print("parsing error")
      }
    }
    .resume()

  }
  
  private func rxFetchHabitat() {
    showLoading()
    
    guard let url = URL(string: habitateURL) else {
      self.rxHabitat.onError(NetworkError.invalidUrl)
      return
    }
    
    let request = URLRequest(url: url)
    
    URLSession.shared.dataTask(with: request) { data, response, error in
      sleep(3)
      if let error = error {
        self.rxHabitat.onError(error)
        return
      }
      
      if let habitat = try? JSONDecoder().decode(TotalHabitat.self, from: data!) {
        self.rxHabitat.onNext(habitat)
      } else {
//        self.rxHabitat.onError(error)
      }
      
      self.rxHabitat.onCompleted()
    }
    .resume()

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
  
  @IBAction func habitatLoadButtonDIdTap(_ sender: Any) {
    rxFetchHabitat()
  }
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.habitat?.results?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
      cell.textLabel?.text = habitat?.results?[indexPath.row].name ?? ""
      return cell
    }
    
    return UITableViewCell()
  }
}
