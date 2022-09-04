//
//  SearchBar.swift
//  rxCafeApp
//
//  Created by seungbong on 2022/09/04.
//

import RxSwift
import RxCocoa

class SearchBar: UISearchBar {
    
    let searchButton = UIButton()
    
    let disposeBag = DisposeBag()
    let searchButtonTapped = PublishRelay<Void>()       // 검색 버튼 탭 터치 이벤트
    var shouldLoadResult = Observable<String>.of("")    // 검색 결과 전달 이벤트
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bind()
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("gg")
    }
    
    private func bind() {
        // 키보드 검색 버튼과, 커스텀 검색 버튼 이벤트를 동시에 처리하기
        Observable
            .merge(
                self.rx.searchButtonClicked.asObservable(), // 키보드 검색 버튼
                self.searchButton.rx.tap.asObservable()     // 검색 UIButton
            )
            .bind(to: searchButtonTapped)
            .disposed(by: disposeBag)
                
        searchButtonTapped
            .asSignal()
            .emit(to: self.rx.endEditing)
            .disposed(by: disposeBag)
        
        shouldLoadResult = searchButtonTapped
            .withLatestFrom(self.rx.text) { $1 ?? "" }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()     // 값이 달라진 경우에만 이벤트를 방출하도록 하는 기능
    }
    
    private func attribute() {
        searchButton.setTitle("검색", for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    private func layout() {
        addSubview(searchButton)
        
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
}

extension Reactive where Base: SearchBar {
    var endEditing: Binder<Void> {
        return Binder(base) { base, _ in
            base.endEditing(true)
        }
    }
}
