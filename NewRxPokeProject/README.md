### Rx를 이용한 포켓몬 도감 앱 만들기

🐹 기존에 만들었던 포켓몬 도감 프로젝트를 Rx를 이용해 재구현해보려 한다.



0. PokedexViewController
   - 포켓몬 도감 화면, 지금까지 잡은 포켓몬들이 보여진다.
   - 포켓몬 

1. MapViewController

   전체 맵 리스트가 보여지고, 선택해 해당 맵으로 이동할 수 있는 뷰이다.

   - 전체 맵 정보 불러오기

     ```swift
     var rxHabitatList = PublishSubject<[HabitatInfo]>()
     
     private func rxFetchHabitatList() {
         guard let url = URL(string: HabitateListURL) else {
           self.rxHabitatList.onError(NetworkError.invalidUrl)
           return
         }
         
         showLoading()
         
         URLSession.shared.rx.data(request: URLRequest(url: url))
           .subscribe(onNext: { data in
             if let habitat = try? JSONDecoder().decode(TotalHabitat.self, from: data) {
               self.rxHabitatList.onNext(habitat.results ?? [])
             }
           }, onCompleted: {
             self.hideLoading()
           })
           .disposed(by: disposeBag)
       }
     ```

     - 전체 맵 정보는 onNext를 직접 넣어줄 수 있는 PublishSubject로 구현했다.
     - `URLSession.shared.rx.data(request:)`를 사용해, Request로 요청한 결과 data를 Observable로 전달받아 처리하였다. 전달받은 값은 `rxHabitatList` 에 `onNext` 하여 데이터를 전달하였다.

   - 뷰 바인딩 하기

     ```swift
       var rxHabitat = PublishSubject<PokeHabitat>()		// 서식지 개별 정보
       var rxSpecies = PublishSubject<PokeSpecies>()		// 포켓몬 종 정보
     
     private func bindUI() {
         rxHabitatList
           .observe(on: MainScheduler.instance)
           .bind(to: habitatTableView.rx.items(cellIdentifier: "cell",
                                               cellType: UITableViewCell.self)) { (row, element, cell) in
             cell.textLabel?.text = self.transferMapName(englishName: element.name)
           }
           .disposed(by: disposeBag)
         
         habitatTableView.rx.modelSelected(HabitatInfo.self)
           .subscribe(onNext: { habitat in
             let selectedHabitatUrl = habitat.url
             self.rxFetchHabitat(urlString: selectedHabitatUrl)
           })
           .disposed(by: disposeBag)
         
         rxHabitat
           .observe(on: MainScheduler.instance)
           .subscribe(onNext: {
             self.rxFetchRandomSpecies(from: $0)
           }, onError: {
             print($0.localizedDescription)
           })
           .disposed(by: disposeBag)
         
         rxSpecies
           .observe(on: MainScheduler.instance)
           .subscribe(onNext: { sepecies in
             self.moveToField(with: sepecies)
           })
           .disposed(by: disposeBag)
       }
     ```

     - `rxHabitatList` 에 데이터가 들어오면 TableView에 바인딩하였다.
     - `habitatTableView.rx.modelSelected` 를 이용해 TableView에 셀 선택이벤트를 캐치해 처리하였다.
     - 나머지 네트워크 요청으로 받아 처리가 필요한 `rxHabitat` , `rxSpecies ` 도 동일하게 구현하였다.

2. FieldViewController

   서식지에 사는 포켓몬 중 랜덤하게 출현한 포켓몬을 잡을 수 있는 뷰이다.

   - 포켓몬 불러오기

     ```swift
     var pokemon = PublishSubject<Pokemon>()
     
     pokemon
           .observe(on: MainScheduler.instance)
           .subscribe(onNext: {
             if let imageUrl = $0.sprites?.front_default,
                let url = URL(string: imageUrl),
                let imageData = try? Data(contentsOf: url) {
               self.pokeImageView.image = UIImage(data: imageData)
               self.fieldTopText.text = "\($0.name)이(가) 나타났다!"
             }
           })
           .disposed(by: disposeBag)
     ```

     - 동일한 방식으로 PublishSubject를 이용해 응답받은 포켓몬 정보를 바인딩해주었다.

   - 포켓몬 잡기

     ```swift
       let catchResult =  PublishSubject<CatchResult>()
     
         catchButton.rx.tap	 // 포켓몬 잡기 버튼 선택 
           .subscribe(onNext: {
             self.catchResult.onNext(self.getCatchResult())
           })
           .disposed(by: disposeBag)
         
         catchResult
           .subscribe(onNext: { [weak self] result in
             guard let self = self else { return }
             self.fieldBottomText.text = result.description
             self.fieldBottomText.textColor = result.textColor
           })
           .disposed(by: disposeBag)
         
         catchResult
           .delay(.seconds(2), scheduler: MainScheduler.instance)
           .subscribe(onNext: {
             if $0 == .runAway || $0 == .captured {
               self.dismiss(animated: true)
             }
           })
           .disposed(by: disposeBag)
     
     ```

     - `catchButton.rx.tap` 버튼 탭 이벤트 바인딩을 통해, 캐치결과 값에 onNext 값을 보내준다.
     - `catchResult` 에 이벤트가 발생하면 화면 레이블의 텍스트와 컬러값을 바꿔주고, `.dealy`를 이용해 2초 뒤에 화면이 닫히도록 처리하였다.