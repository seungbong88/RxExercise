//
//  RepositoryListViewController.swift
//  GithubProject
//
//  Created by SeungHee Han on 2022/08/07.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryListViewController: UITableViewController {
    
    private let organization = "Apple"
    private var repositories = BehaviorSubject<[Repository]>(value: [])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = organization + "Repositories"
        navigationItem.title = title
        
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.register(RepositoryListCell.self,
                           forCellReuseIdentifier: RepositoryListCell.id)
        tableView.rowHeight = 148
    }
    
    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.fetchRepositories(of: "Apple")
        }
    }
    
    func fetchRepositories(of organization: String) {
        Observable.from([organization])
            .map { organization -> URL in
                return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
            }
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .filter { (response, _ ) in
                return 200..<300 ~= response.statusCode
            }
            .map { (_, data) -> [[String: Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data),
                      let result = json as? [[String: Any]] else {
                    return []
                }
                return result
            }
            .filter{
                $0.isEmpty == false
            }
            .map { result -> [Repository] in
                return result.compactMap { dic in
                    guard let id = dic["id"] as? Int,
                          let name = dic["name"] as? String,
                          let description = dic["description"] as? String,
                          let stargazersCount = dic["stargazers_count"] as? Int,
                          let language = dic["language"] as? String else {
                        return nil
                    }
                    
                    return Repository(id: id, name: name, description: description, stargazersCount: stargazersCount, language: language)
                }
            }
            .subscribe(onNext: { [weak self] newRepositories in
                self?.repositories.onNext(newRepositories)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension RepositoryListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try repositories.value().count
        } catch {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryListCell.id) as? RepositoryListCell else {
            return UITableViewCell()
        }
        guard let repository = try? repositories.value()[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.repository = repository
        return cell
    }
}
