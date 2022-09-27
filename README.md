# RxTestProject



#### RxSwift를 사용하는 이유?

- 비동기로 처리되는 경우에는 호출한 함수가 끝난 뒤에 클로저를 사용해서 처리한다.
- 비동기로 처리된 후에 다시 비동기로 프로세스를 처리할 경우, 사용하는 콜백이 많아지고 코드의 가독성은 떨어진다. (클로저를 중복으로 사용하기 때문!)
- 이렇게 클로저로 응답을 받지 않고, 일반 함수에서 리턴을 받는 것 처럼 비동기 처리를 하기 위해 사용하는 것이 RxSwift라고 한다



#### [목차]

1. [Observable](#1.-observable)
   - Observable 이란
   - Observable의 생명주기
   - Observable의 생성
   - Subscribe
   - Disposing
   - Observable과 Observer
2. [Subject, Relay](#2.-subject,-relay)
   - Subject 란?
   - Subject의 종류
   - 추가 Observable
   - Realy
3. [Operator](#3.-operator)
   - Filtering Operator
   - Combining Operator
   - Time Based Operator





## 1. Observable



#### Observable 이란

- Obsevable은 비동기 등 처리를 통해 '나중에 생기는 데이터'를 처리하는 객체라고 생각하면 된다.

- Observable은 for-each 로 대표되는 swift의 Sequence와 동일한 개념이다.



#### Observable의 생명주기

1. create
2. Subscribe
3. onNext
4. onCompleted / onError
   - onError 나 onCompleted 이벤트가 발생하면 해당 Observable은 이후 데이터를 처리하지 않는다.
5. disposed
   - sequence를 종료하고 싶다면 disposed를 호출하라

```swift
RxSwift의 핵심
1. 비동기로 생기는 데이터를 Observable 로 감싸서 리턴하는 방법
2. Observable 로 오는 데이터를 받아서 처리하는 방법
```



#### Observable의 생성

1. 직접 생성

   ```swift
   let observable = Observable<String>.create() { emitter in
         emitter.onNext("Hello")
   			emitter.onError(error)
         emitter.onCompleted()
         
         return Disposables.create()
       }
   ```

2. .just : 오직 하나의 요소를 포함하는 Observable Sequence 생성

   ```swift
   let observable: Observable<Int> = Observable<Int>.just(1)
   ```

3. of :  가변적인 요소를 포함하는 Observable Sequance 생성

   ```swift
   let observables2: Observable<[Int]> = Observable.of(1, 2, 3)
   ```

4. from : array 의 각 요소로 Observable Sequence 생성

   ```swift
   let observables3: Observable<Int> = Observable.from([1, 2, 3])
   ```

   - 동일한 sequence를 just로 생성한다면,

     ```swift
     let observables3: Observable<[Int]> = Observable.just([1, 2, 3])
     ```

5. empty : 요소를 가지지 않는 Observable, completed 이벤트만 방출한다.

   ```swift
   let observable = Observable<Void>.empty()
   ```

6. never : 어떠한 이벤트도 방출하지 않는 Observable 

   ```swift
   let observable = Observable<Any>.never()
   ```

7. range : start 부터 count 만큼의 크기를 갖는 Observable을 생성한다.

   ```swift
   let observable = Observable<Int>.range(start: 3, count: 6) // 3, 4, 5, 6, 7 방출
   ```

8. repeatElement: 지정된 element를 계속 방출한다.

   ```swift
   let observable = Observable<Int>.repeatElement(6) // 6, 6, 6, 6 ....
   ```

   

#### Subscribe

- Observable을 구독하는 행위 

- subscribe 함수를 이용해 Observable의 데이터 방출을 감시한다. Observable은 Subscribe 되기 전까지 어떤 이벤트도 방출하지 않는다.


```swift
let observable = Observable.of(1, 2, 3)
     observable.subscribe({ (event) in
    	 print(event)
 	})
```

- Subscribe 는 bind로 방출되는 값을 객체에 바로 대입해 줄 수 있다.

  ```swift
  // Subscribe 를 사용해 방출되는 값을 label에 넣는 경우
  stringObservable.subscribe(onNext: { self.label.text = $0 })
      
  // bind를 사용하는 경우
  stringObservable.bind(to: label.rx.text)
  ```

  - bind 를 사용하면 더 간단하게 값을 넣어줄 수 있다.



#### Disposing

- 구독 취소

- 더이상 데이터 방출을 기다리지 않고 구독을 취소하는 행위이다.

```swift
 let observable = Observable.of(1, 2, 3)
 let subscription = observable.subscribe({ num in
     print(num)
 })
 subscription.dispose()
```

- 구독 취소를 하는 이유 : 무한히 이벤트 방출을 기다리는 객체를 남겨두는 것은 메모리 누수를 초래할 수 있기 때문



####  Observable과 Observer

- Observable : 데이터를 관찰하다가 이벤트가 발생하면 방출하는 객체
  - Observable = Observable Sequence = Sequence

- Observer : Observable 을 구독하다 데이터가 방출되면 그에 관련된 처리를 하는 객체

```
🙋‍ Observable은 Subscribe가 있을 때마다 이벤트를 방출 하게 됨!
```





## 2. Subject, Relay



#### Subject 란?

```text
Subject는 브릿지나 프록시의 역할을 한다. 이는 ReactiveX에서 Observer와 Observable 모두의 구현이 가능하기 때문이다. Subject가 Observer이기 때문에 하나 이상의 Observable 을 Subscribe 할 수 있고, Observable 이기 때문에 아이템을 보내고 재방출 할 수 있다. 
```

- Subject = Observable + Observer 

- Observable은 생성할 때 방출해야 할 데이터를 넣어주고, Subscribe 할 때 이 데이터를 방출했다면, Subject는 *외부에서 데이터를 넣어줄 수 있다*는 데에 가장 큰 차이가 있다.

  ```swift
  let subject = BehaviorSubject<[Int]>(value: [1, 2, 3])
      
  // subject 구독 부분
  subject.subscribe(onNext: { print($0) })
      
  // subject 데이터 전달 부분
  subject.onNext([6, 7, 8])
  
  // subject 구독 해제 부분
  subject.disposed(by: disposeBag)
  ```

  - 최초 이벤트는 [1, 2, 3] 이 발생하며, 외부에서 onNext를 이용해 데이터를 넣어줬기 때문에 이후 [4, 5, 6] 이벤트가 한 번 더 발생한다.



#### Subject의 종류

1. AsyncSubject

   - **<u>마지막 아이템만</u>** **<u>Observable이 동작을 완료한 후</u>**에 방출한다. 만약 Observable이 어떤 값도 방출하지 않는다면 AsyncSubject 또한 어떤 값도 방출하지 않는다.
   - 동일한 값을 다른 Observer 들에게 방출할 수 있다. 하지만 Observable이 error로 끝이 나면 어떤 아이템도 방출하지 않고, 단순히 에러에 대한 알림만 방출하게 된다.

   ```swift
   let asyncSubject = AsyncSubject<Int>()
   asyncSubject.onNext(3)
   asyncSubject.onNext(4)
       
   asyncSubject.subscribe(onNext: { print("[observer 1] \($0)") })
   
   asyncSubject.onNext(5)
       
   asyncSubject.subscribe(onNext: { print("[observer 2] \($0)") })
   
   asyncSubject.onCompleted()
       
   asyncSubject.subscribe(onNext: { print("[observer 3] \($0)") })
   
   // print 
   [observer 1] 5
   [observer 2] 5
   [observer 3] 5
   ```

   - onCompleted가 발생한 후에 각 observer들은 마지막 아이템은 5를 반환한다

     

2. BehaviorSubject

   - Observer가 BehaviorSubject를 구독할 때, Obsevable에 의해 <u>가장 최근에 방출된 아이템부터 방출을 시작</u>한다. 

   - Observable이 에러로 종료될 경우 BehaviorSubject는 어떤 아이템도 반환하지 않으며 에러만 방출한다.

   ```swift
   let asyncSubject = BehaviorSubject<Int>(value: 2)
   asyncSubject.onNext(3)
       
   asyncSubject.subscribe(onNext: { print("[observer 1] \($0)") })
   asyncSubject.onNext(4)
   asyncSubject.onNext(5)
       
   asyncSubject.subscribe(onNext: { print("[observer 2] \($0)") })
   asyncSubject.onCompleted()
   
   // print 
   observer 1] 3
   [observer 1] 4
   [observer 1] 5
   [observer 2] 5
   ```

   

3. PublishSubject

   -  Observer에게 Observable을 구독한 다음에 방출되는 아이템들을 방출한다.

   -  PublishSubject는 생성하자마자 아이템을 방출하기 시작한다. 

   ```swift
   let asyncSubject = PublishSubject<Int>()
   asyncSubject.onNext(3)
       
   asyncSubject.subscribe(onNext: { print("[observer 1] \($0)") })
   asyncSubject.onNext(4)
   asyncSubject.onNext(5)
       
   asyncSubject.subscribe(onNext: { print("[observer 2] \($0)") })
   asyncSubject.onNext(6)
   asyncSubject.onCompleted()
   
   // print 
   [observer 1] 4
   [observer 1] 5
   [observer 1] 6
   [observer 2] 6
   ```

4. ReplaySubject

   - 구독 시에 발생했던 모든 아이템을 다시 한 번 방출하고, 이후 데이터를 방출한다.
   - 메모리를 효율적으로 사용하기 위해서 최초 생성 시 버퍼 크기를 선언해준다.



#### Relay란?

- Relay는 Subject를 Wrapping 한 것, Subject와 거의 유사하게 동작한다
- 차이점은 Relay는 `onNext(_:)` 대신에 `accept(_:)` 를 사용하며, onError나 onCompleted를 사용해서 멈출 수 없다는 것이다.
- 그렇기 때문에 Relay는 이벤트가 결코 종료되지 않음을 보장한다.



#### Relay의 종류

1. AsyncRelay
2. PublishRelay
3. BehaviorRelay
4. ReplayRelay



#### Trait 이란?

Traits는 Observable Sequance 프로퍼티들을 인터페이스 경계를 넘어서 communicate 할 수 있도록 도와주는 것.



#### Trait의 종류

- ControlProperty / ControlEvent
- Driver
- Signal



#### Trait의 특징

- 에러를 발생시키지 않는다.
- 메인스케줄러에서 Observe 된다
- 메인스케쥴러에서 Subscribe 된다.
- Signal을 제외하고 리소스를 공유한다.



#### Driver

에러를 방출하지 않고, 메인스레드에서 동작하며, 백그라운드 스레드에서 UI 변화가 만들어지는 것을 회피하는 특별한 Observable



#### Signal

- 실패하지 않음
- 연결된 이벤트는 공유됨
- 모든 이벤트는 메인스케쥴러에서 전달됨

- Driver와 Signal의 차이점은 BahaviorSubject와 Publish Subject의 차이와 다소 비슷하다.
- 둘 중 어떤 것을 써야할지 헷갈릴 때에는 "리소스를 연결할 때 마지막에 발생한 이벤트를 반복할 필요가 있는가?" 를 생각하고 그렇다면 Driver를, 그렇지 않다면 Signal을 사용하면 된다.



#### 추가 Observable

1. Single
   - success 이나 error 만 체크하는 간단한 Observable
     - success(value) = onNext + completed 
   - .asSingle 로도 사용 가능


2. Maybe

   - 성공적으로 completed 되더라도 아무런 값도 방출하지 않음

   - .asMaybe 로도 사용 가능


3. Completable
   - completed 또는 Error 만 방출함 (어떠한 값도 방출하지 않음)





## 3. Operator



#### Filtering Operator

- ignoreElement : onNext의 이벤트를 무시하는 operator

- element(at:) : 특정 인덱스의 sequence 가 들어올 때에만 방출하는 Filtering operator

- take() : n 번만 expose 된 값들만 처리하고 그 뒤로는 무시하는 operator

- enumerated() : 방출된 element 와 index를 함께 내려주는 operator 

  - 기존 : element

  - enumerated : (index, element)

#### Combining Operator

여러 Observable을 합치는 Operator

- StartWith(:) : Observable 이벤트 발생 시 초기값을 지정해주는 방법

- merge : 순서를 보장하지 않고 각 Observable을 더함

- combineLatest : 가장 최신의 값들을 매칭하여 더함

  ```swift
  let 성 = PublishSubject<String>()
  let 이름 = PublishSubject<String>()
  
  let 성명 = Observable
      .combineLatest(성, 이름) { (성, 이름) in
          성 + 이름
      }
  
  성명
      .subscribe(onNext: {
          print($0)
      })
  
  성.onNext("이")
  성.onNext("박")
  이름.onNext("철수")
  성.onNext("김")
  이름.onNext("영구")
  이름.onNext("유리")
  ```

- zip : 순서를 보장하면서 두 개의 Observable 을 더함


- withLatestFrom : 방아쇠역할을 하는 Obervable이 이벤트 방출을 시작하면 연결된 다른 Observable 이 동작을 하며, 마지막 값만을 방출한다. (방아쇠 Observable이 이벤트를 발생시키지 않으면 다른 Observable은 어떤 값도 방출하지 않음)

- sample : withLatestFrom 과 동작은 같으나, 방아쇠를 몇 번 발생시키든 이벤트든 단 한 번만 발생함.

- amb : 두 가지의 observable 을 구독할 때, 둘 중 '먼저' 이벤트를 방출한 Observable의 값만을 방출함

- switchLatest : 마지막 시퀀스의 아이템만 구독함

- recude : 방출되는 값들의 연산의 합을 방출

- scan : 방출되는 값들과 중간 연산의 결과를 모두 방출

  ```swift
  print("----reduce----")
  
  Observable.from((1...10))
      .reduce(0, accumulator: +)
      .subscribe(onNext: {
          print($0)					// return 55
      })
      .disposed(by: disposeBag)
  
  print("----scan----")
  
  Observable.from((1...10))
      .scan(0, accumulator: +)
      .subscribe(onNext: {
          print($0)		// return 1, 3, ... , 55
      })
      .disposed(by: disposeBag) 
  ```


#### Time Based Operator

1. replay : 이벤트 방출 후에 이벤트 발생 시 정해놓은 버퍼 만큼의 이벤트를 방출

   ```swift
   let 인사말 = PublishSubject<String>()
   let 반복하는앵무새 = 인사말.replay(2)	// 구독 전 발생한 이벤트를 2개까지 방출
   반복하는앵무새.connect()
   
   인사말.onNext("hello")
   인사말.onNext("니하오마")
   인사말.onNext("hi")
   
   반복하는앵무새
       .subscribe(onNext: {
           print($0)
       })
       .disposed(by: disposeBag)
   
   인사말.onNext("안녕")	// 구독 이후 발생된 이벤트는 그대로 방출
   
   // [console]
   // "니하오마"
   // "hi"
   // "안녕"
   ```

2. replayAll : 버퍼 없이 구독 이전에 발생한 모든 값을 방출

3. buffer : 타이머를 만들어 일정 시간동안 반복해서 이벤트를 방출할 때 사용

4. delaySubscription : 특정 시간 구독을 지연시킴. 

5. delay : 구독 뿐 아니라 시퀀스 자체를 지연시키는 operator

6. interval : 특정 시간동안 반복하는 간단한 방법~

   ```swift
   Observable<Int>
       .interval(.seconds(2), scheduler: MainScheduler.instance)
       .subscribe(onNext: {
           print($0)
       })
       .disposed(by: disposeBag)
   ```

7. timer :  특정 시간동안 반복하고 종료시키는 강력한 방법~~~

   ```swift
   Observable<Int>
       .timer(.seconds(5),					// 구독 이후 5초 후에
              period: .seconds(1),	// 1초 간격으로 반복
              scheduler: MainScheduler.instance) // 메인 스케쥴러에서
       .subscribe(onNext: {
           print($0)
       })
       .disposed(by: disposeBag)
   ```

8. timeout : 특정 시간 동안 데이터를 방출시키며, 시간이 지나면 에러를 방출하는 operator

   ```swift
   버튼.rx.tap
       .do (onNext: {
           print("tap")
       })
       .timeout(.seconds(5), scheduler: MainScheduler.instance)
       .subscribe({
           print($0)	// 5초 후에는 탭 이벤트가 발생하면 error 로 방출
       })
       .disposed(by: disposeBag)
   ```

   - 통신 타임아웃 처리에 사용하면 될듯싶다.



#### 에러 관리

- catch : 에러를 확인하고 처리하는 방법

- catchAndReturn : 에러가 발생하면 특정 값을 onNext로 보내주는 방식으로 처리하는 방법

- retry(:) : 정해진 횟수만큼 시도하고, 그 안에 정상적인 응답이 없으면 멈추는 처리방법





---

*참고 : 도서 RxSwift Reactive Programming With Swift, 유튜브 곰튀김 RxSwift 4시간에 끝내기, 강의 패스트캠퍼스 30개 프로젝트로 배우는 iOS 앱 개발 with Swift 초격차 패키지 Online 강의*

