//
//  APIConroller.swift
//  WeatherAppProject
//
//  Created by seunghee on 2022/09/19.
//

import Foundation
import RxSwift

class APIController {
    
    static let shared = APIController()
    
    func loadWeather(for city: String) -> Observable<Weather> {
        var baseUrl = "https://api.openweathermap.org/data/2.5/weather"
        let apiKey = "8d0c6a9f7bae2b2c84a547c67de071ef"
        
        baseUrl = baseUrl + "?appid=\(apiKey)&units=metric&q=\(city)"
        return fetchData(urlString: baseUrl)
            .map { data in
                try JSONDecoder().decode(Weather.self, from: data)
            }
    }
    
    private func fetchData(urlString: String,
                           method: String = "GET") -> Observable<Data> {
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encodedUrlString!)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let urlSession = URLSession.shared
        return urlSession.rx.data(request: request)
    }
}
