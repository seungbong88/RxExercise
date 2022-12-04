//
//  NetworkAgent+RxSwift.swift
//  RxPokemonProject
//
//  Created by seungbong on 2022/12/04.
//

import Foundation
import RxSwift
import RxCocoa

extension NetworkAgent {
    
    
    /// RxSwift 를 이용한 HTTP GET 요청
    /// - Parameters:
    ///   - urlString: 요청할 url
    func rxRequestGet(_ urlString: String) -> Observable<TotalHabitat.Response> {
        return Observable<TotalHabitat.Response>.create { emitter in
            guard let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let url = URL(string: encodedString) else {
                emitter.onError(NetworkError.invalidUrl)
            }
            
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    emitter.onError(error)
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode) else {
                    emitter.onError(NetworkError.serverError)
                }
                
                guard let data = data,
                      let habitat = JSONDecoder().decode(TotalHabitat.Response.self, from: data) as? TotalHabitat else {
                    emitter.onError(NetworkError.parsingError)
                }
                
                emitter.onNext(habitat)
            }.resume()
        }
    }
}
//

func test() -> Single<Any> {
    return Single.create { single in
          let request = Alamofire.request(    // Networking에는 Alamofire를 사용했다.
            url,
            method: .get,
            parameters: parameters,
            headers: headers
            )
            .responseData { response in

              switch response.result {
              case let .success(jsonData):
                do {
                  let returnObject = try JSONDecoder().decode(Success.self, from: jsonData)
                  single(.success(.success(returnObject)))
                  // single의 success. NetworkResult.success에 담아 보낸다.
                } catch let error {
                  single(.error(error))
                  // JSON 파싱에러 각자 알맞게 처리해주면 될 것 같다.
                }

              case let .failure(error):
                if let statusCode = response.response?.statusCode {
                  if let networkError = NetworkError(rawValue: statusCode){
                    single(.success(.error(networkError)))
                    // single의 success. NetworkResult.error에 담아 보낸다.
                  }
                }
              }
          }

          return Disposables.create {
            request.cancel()
          }
        }

}


