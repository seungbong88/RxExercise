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



> 🙋‍♀️ PublishSubject 를 통해서, 이벤트가 방출 되고난 이후에 해당 값에 접근할 필요가 있을 때에는 어떻게 해야 할까?

- 예를 들어서, 네트워크 요청을 통해 값을 가져온 이후에 버튼을 선택할 때 그 객체의 값을 가져와야 할 때에는 어떻게 해야할까?

- 1. `PublishSubject<Pokemon>` 에 이벤트가 방출되면 `Pokemon`  타입의 객체에 한 번 더 저장한다.

     - 객체를 두 번 중복으로 사용하는 방법은 효율적이지 않아 보인다.

  2. `BehaviorSujbect<Pokemon>` 으로 바꾸고, subscribe를 한 번 더하여 최근에 전달 받은 Pokemon 값을 꺼낸다.

     - BehaviorSubject는 생성 시에 초기값을 지정해줘야 한다. `BehaviorSujbect<Pokemon>(value:)`

       아직 Pokemon 값을 가져오지 않은 상태에서는 초기 값에 무의미한 값을 넣어주면 될까?

  3. 따로 접근할 수 있는 메서드가 있나?

- rxJs에는 `getValue()` 라는 메서드가 존재하지만, subject가 실행되고 있지 않을 때에는 에러가 발생할 수 있기 때문에 권하지 않는다고 한다. swift의 Subject에는 `getValue()` 메서드가 존재하지 않는다.

  - 해결방법 1. `BehaviorSubject` 를 사용하라. 초기에 값을 넣어줘야하지만 구독하는 방법을 사용하라.
  - 해결방법 2. `ReplaySubject` 를 사용하라. 새로 구독하여 캐시에 있는 값을 꺼내 사용하라.
  - 해결방법 3. `A.WithLatestFrom(B)` 연산을 사용하라. 이 연산은 Observable A가 방출할 때 Observable B가 가장 최근에 방출한 값을 가져올 수 있다. 이것은 [a, b] array형태로 두 값을 제공할 것이다.
  - 해결방법 4. `A.combineLates(B)` 연산을 사용하라. 이 연산은 A와 B Observable로부터 가장 최근의 값을 제공할 것이다. 매번 A 혹은 B가 방출 할때에. 이것 또한 array 형태로 값을 제공한다.

  - 해결방법 5. `publishReplay()` 

- 결론

  - Rx는 Stream으로 값의 흐름을 다루기 때문에, 지속적으로 가지고 접근할 필요가 있는 값은 별도의 변수에 저장을 해두고, 특정 상태를 체크하여 UI를 변경해주는 작업같이 값을 저장할 필요가 없는 경우에는 바인딩만 하여 처리하면 될 듯 하다!