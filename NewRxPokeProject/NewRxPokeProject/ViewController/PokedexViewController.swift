//
//  PokedexViewController.swift
//  NewRxPokeProject
//
//  Created by seungbong on 2022/12/18.
//

import UIKit
import RxSwift
import RxCocoa

class PokedexViewController: UIViewController {
  
  @IBOutlet weak var pokedexCollectionView: UICollectionView!
  @IBOutlet weak var startButton: UIButton!
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let testBehaviorSubject = BehaviorSubject<Int>(value: 0)
    testBehaviorSubject.onNext(1)
    
    testBehaviorSubject
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
    
    testBehaviorSubject
      .subscribe(onNext: { print($0) })
      .disposed(by: disposeBag)
  }
  
}
