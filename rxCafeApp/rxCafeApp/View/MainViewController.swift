//
//  MainViewController.swift
//  rxCafeApp
//
//  Created by seungbong on 2022/09/04.
//

import RxSwift
import RxCocoa
import SnapKit
import Foundation

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let searchBar = SearchBar()
    let blogListView = BlogListView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTest()
//        bind()
//        attribute()
//        layout()
    }
    
    private func bind() {
        searchBar.shouldLoadResult.subscribe(onNext: {
            print("검색어 : \($0) ")
        })
        .disposed(by: disposeBag)
        
        // load Data
        let keyword: String = "RxSwift"
        let hostUrl = "https://dapi.kakao.com"
        let apiKey = "685b42b5fabc0694fa0dae2be55722dd"
        
        Observable
            .of(hostUrl)
            .map { $0 + "/v2/search/blog" + "?query=" + keyword }
            .map { urlString -> URL? in
                URL(string: urlString)
            }
            .filter{ $0 != nil }
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Authorization", forHTTPHeaderField: "KakaoAK \(apiKey)")
                return request
            }
        // URLSession ㄲ
    }
    
    private func attribute() {
        view.backgroundColor = .white
    }
    
    private func layout() {
        [searchBar, blogListView].forEach { view.addSubview($0) }
        
        searchBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        blogListView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
        }
    }
    
    private func fetchOrigianl() {
        var host = "https://dapi.kakao.com"
        let apiKey = "685b42b5fabc0694fa0dae2be55722dd"
        let urlString = host + "/v2/search/blog" + "?query=rxswift"
        let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { ( data, response, error) in
            struct Response: Decodable {
                var documents: [BlogListCellData]
            }
            let decoder = JSONDecoder()
            if let data = data,
               let json = try? decoder.decode(Response.self, from: data) {
                print(json.documents)
            }
        }.resume()
    }
}
