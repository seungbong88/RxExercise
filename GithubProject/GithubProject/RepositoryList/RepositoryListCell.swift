//
//  RepositoryListCell.swift
//  GithubProject
//
//  Created by SeungHee Han on 2022/08/07.
//

import UIKit
import SnapKit

class RepositoryListCell: UITableViewCell {
    static let id = "RepositoryListCell"
    var repository: Repository?
    
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let starImageView = UIImageView()
    let starLabel = UILabel()
    let languageLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [
            nameLabel, descriptionLabel,
            starImageView, starLabel, languageLabel
        ].forEach {
            addSubview($0)
        }
        
        initUI()
    }
    
    private func initUI() {
        guard let repository = repository else { return }
        nameLabel.text = repository.name
        descriptionLabel.text = repository.description
        descriptionLabel.numberOfLines = 2
        starImageView.image = UIImage(systemName: "star")
        starLabel.text = String(repository.stargazersCount)
        languageLabel.text = repository.language
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).inset(3)
            $0.leading.trailing.equalTo(nameLabel)
        }
        
    }
}
