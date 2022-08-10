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
        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        
        descriptionLabel.text = repository.description
        descriptionLabel.numberOfLines = 2
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .light)
        
        starImageView.image = UIImage(systemName: "star")
        
        starLabel.text = String(repository.stargazersCount)
        starLabel.font = .systemFont(ofSize: 12)
        
        languageLabel.text = repository.language
        languageLabel.font = .systemFont(ofSize: 12)
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(nameLabel)
        }
        starImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            $0.leading.equalTo(descriptionLabel.snp.leading)
            $0.width.height.equalTo(20)
        }
        starLabel.snp.makeConstraints {
            $0.leading.equalTo(starImageView.snp.trailing).offset(5)
            $0.centerY.equalTo(starImageView)
        }
        languageLabel.snp.makeConstraints {
            $0.leading.equalTo(starLabel.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().offset(18)
            $0.centerY.equalTo(starLabel)
        }
    }
}
