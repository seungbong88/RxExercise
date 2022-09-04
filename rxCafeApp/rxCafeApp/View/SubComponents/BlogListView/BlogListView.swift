//
//  BlogListView.swift
//  rxCafeApp
//
//  Created by seungbong on 2022/09/04.
//

import RxSwift
import RxCocoa
import SnapKit

class BlogListView: UITableView {
    
    let disposBag = DisposeBag()
    
    let cellData = PublishSubject<[BlogListCellData]>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        bind()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        cellData
            .asDriver(onErrorJustReturn: [])
            .drive(self.rx.items) { tableView, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: BlogListCell.id,
                                                         for: index) as! BlogListCell
                cell.setData(data)
                return cell
            }
            .disposed(by: disposBag)
    }
    
    private func attribute() {
        self.backgroundColor = .white
        register(BlogListCell.self, forCellReuseIdentifier: BlogListCell.id)
        self.rowHeight = 100
    }
}
