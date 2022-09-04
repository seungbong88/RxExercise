//
//  BlogListCell.swift
//  rxCafeApp
//
//  Created by seungbong on 2022/09/04.
//

import UIKit
import Kingfisher
import SnapKit

class BlogListCell: UITableViewCell {
    
    static let id = "BlogListCell"
    
    let thumbnailImageView = UIImageView()
    let nameLabel = UILabel()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        attribute()
        layout()
    }
    
    private func attribute() {
        thumbnailImageView.contentMode = .scaleAspectFit
        
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.numberOfLines = 2
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    
    private func layout() {
        [thumbnailImageView, nameLabel, titleLabel, dateLabel].forEach {
            self.addSubview($0)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.leading).offset(12)
            $0.top.equalTo(thumbnailImageView)
            $0.trailing.equalToSuperview().inset(12)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        dateLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    func setData(_ data: BlogListCellData) {
        thumbnailImageView.kf.setImage(with: URL(string: data.thumbnail!)!,
                                       placeholder: UIImage(systemName: "photo"))
        nameLabel.text = data.blogname
        titleLabel.text = data.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
//        dateLabel.text = formatter.string(from: data.datetime ?? Date())
    }
}
