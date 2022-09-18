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
    
    searchTextField.delegate = self
    
    rxWeather
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { data in
        self.cityNameLabel.text = data.name
        self.temperatureLabel.text = "\(data.main?.temp ?? 0)"
        self.humanityLabel.text = "\(data.main?.humidity ?? 0)"
      })
      .disposed(by: disposeBag)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.text?.count ?? 0 <= 0 { return false }
    
    rxFetchData(city: textField.text!)
      .subscribe(onNext: {
        self.rxWeather.onNext($0)
      }, onError: {
        self.rxWeather.onError($0)
      })
      .disposed(by: disposeBag)

    return true
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
