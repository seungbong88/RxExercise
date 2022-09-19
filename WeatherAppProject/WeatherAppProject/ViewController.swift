//
//  ViewController.swift
//  WeatherAppProject
//
//  Created by seungbong on 2022/09/05.
//

import RxSwift
import RxCocoa
import Combine

class ViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var humanityLabel: UILabel!
  
  let disposeBag = DisposeBag()
  var weather: Weather?
  
  let rxWeather = PublishSubject<Weather>()
  
  enum NetworkError: Error {
    case unexceptedError
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    bind()
  }
  
  private func bind() {
    let search = searchTextField
      .rx.controlEvent(.editingDidEndOnExit)
      .map { self.searchTextField.text ?? "" }
      .filter { !$0.isEmpty }
      .flatMapLatest { text in
        APIController.shared
          .loadWeather(for: text)
      }
      .asDriver(onErrorJustReturn: Weather(name: "", icon: "", main: nil))
    
    search
      .map { $0.name }
      .drive(cityNameLabel.rx.text)
      .disposed(by: disposeBag)
    
    search
      .map { "\($0.main?.temp ?? 0) ° C" }
      .drive(temperatureLabel.rx.text)
      .disposed(by: disposeBag)
    
    search
      .map { "\($0.main?.humidity ?? 0) %"}
      .drive(humanityLabel.rx.text)
      .disposed(by: disposeBag)
  }
}

// Rx Networking
extension ViewController {
  func rxFetchData(city: String) -> Observable<Weather> {
    return Observable<Weather>.create { emitter in
      
      var baseUrl = "https://api.openweathermap.org/data/2.5/weather"
      let apiKey = "8d0c6a9f7bae2b2c84a547c67de071ef"
      
      baseUrl = baseUrl + "?appid=\(apiKey)&units=metric&q=\(city)"
      baseUrl = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
      
      let url = URL(string: baseUrl)!
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      
      URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          emitter.onError(error)
        }
        
        if let data = data,
           let weather = try? JSONDecoder().decode(Weather.self, from: data) {
          emitter.onNext(weather)
        } else {
          emitter.onError(NetworkError.unexceptedError)
        }
      }.resume()
      
      return Disposables.create()
    }
  }
}


// Basic Networking
extension ViewController {
  
  func fetchData(city: String) {
    let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    let apiKey = "8d0c6a9f7bae2b2c84a547c67de071ef"
    
    let params = [
      URLQueryItem(name: "appid", value: apiKey),
      URLQueryItem(name: "units", value: "metric"),
      URLQueryItem(name: "q", value: city)
    ]
    
    let encodedUrlString = baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let url = URL(string: encodedUrlString)!
    var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: true)
    urlComponent?.queryItems = params
    
    var request = URLRequest(url: (urlComponent?.url)!)
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let data = data,
         let json = try? JSONDecoder().decode(Weather.self, from: data) {
        
        self.weather = json
        DispatchQueue.main.async {
          self.updateUI()
        }
      }
    }.resume()
  }
    
  func updateUI() {
    guard let weather = self.weather else { return }
    cityNameLabel.text = weather.name
    temperatureLabel.text = "\(weather.main?.temp ?? 0)"
    humanityLabel.text = "\(weather.main?.humidity ?? 0)"
  }
}
