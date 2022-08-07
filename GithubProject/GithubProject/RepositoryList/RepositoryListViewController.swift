//
//  RepositoryListViewController.swift
//  GithubProject
//
//  Created by SeungHee Han on 2022/08/07.
//

import UIKit

class RepositoryListViewController: UITableViewController {
    
    private let organization = "Apple"
    
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
        
    }
}

extension RepositoryListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryListCell.id) as? RepositoryListCell else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = (indexPath.row%2 == 0) ? .darkGray : .white
        return cell
    }
}
