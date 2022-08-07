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
    var repository: String?
    
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
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
