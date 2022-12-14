//
//  MultiGameViewModel.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import CoreLocation

final class MultiGameViewModel: BaseViewModel {

    public let disposeBag: RxSwift.DisposeBag = .init()
    private var timerBag = DisposeBag()
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let resetButtonTapped: Observable<Void>
        let watchOthersLocationButtonTapped: Observable<Void>
        let exitButtonTapped: Observable<Void>
        let gameOverButtonTapped: Observable<Void>
        let toRoomButtonTapped: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let didEnterBackground: Observable<Void>
    }
    
    struct Output {
        let firstLocation: Driver<Coordinate>
        let time: Driver<Int>
        let visitedLocation: Driver<Coordinate>
        let gamePoint: Driver<Int>
        let movedDistance: Driver<Double>
        let playerDataFetched: Driver<[MultiGamePlayerData]>
        let currentLocation: Driver<Coordinate>
        let otherLocation: Driver<Coordinate>
        let gameOver: Driver<Void>
        let unReadChat: Driver<Int>
    }
    private let timerCount = BehaviorRelay(value: 60)
    
    private let firstLocation = PublishSubject<Coordinate>()
    private let visitedLocation = PublishSubject<Coordinate>()
    private let gamePoint = PublishSubject<Int>()
    private let movedDistance = PublishSubject<Double>()
    private let playerDataFetcehd = PublishSubject<[MultiGamePlayerData]>()
    private let currentLocation = PublishSubject<Coordinate>()
    private let otherLocation = PublishSubject<Coordinate>()
    private let gameOver = PublishSubject<Void>()
    private let unReadChat = PublishSubject<Int>()
    
    private let roomId: String
    private let useCase: MultiGameUseCase
    private weak var coordinator: MultiGameCoordinator?
    init
    (
        coordinator: MultiGameCoordinator,
        useCase: MultiGameUseCase,
        roomId: String
    ) {
        self.roomId = roomId
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    func transform(input: Input) -> Output {

        inputBind(input: input)
        
        return Output(
            firstLocation: firstLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0)),
            time: timerCount.asDriver(onErrorJustReturn: -1),
            visitedLocation: visitedLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0)),
            gamePoint: gamePoint.asDriver(onErrorJustReturn: 0),
            movedDistance: movedDistance.asDriver(onErrorJustReturn: 0),
            playerDataFetched: playerDataFetcehd.asDriver(onErrorJustReturn: []),
            currentLocation: currentLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0)),
            otherLocation: otherLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0)),
            gameOver: gameOver.asDriver(onErrorJustReturn: ()),
            unReadChat: unReadChat.asDriver(onErrorJustReturn: 0)
        )
    }
    
    private func inputBind(input: Input) {
        input.viewDidAppear
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.getLocation()
                    .first()
                    .subscribe(onSuccess: { position in
                        guard let position = position else {return}
                        self.firstLocation.onNext(position)
                    })
                    .disposed(by: self.disposeBag)
                
                self.useCase.getLocation()
                    .subscribe { location in
                        self.visitedLocation.onNext(location)
                        self.useCase.updateData(roomId: self.roomId)
                        self.movedDistance.onNext(self.useCase.movedDistance)
                    }
                    .disposed(by: self.disposeBag)
                
                self.useCase.observing(roomID: self.roomId)
                    .subscribe { players in
                        if players.count >= 2 {
                            self.playerDataFetcehd.onNext(players)
                        }
                    }
                    .disposed(by: self.disposeBag)
                
                self.useCase.gameOver(roomID: self.roomId)
                    .subscribe { over in
                        if over {
                            self.gameOver.onNext(())
                            self.gameOverAction(time: 60)
                            
                        }
                    }
                    .disposed(by: self.disposeBag)
                
                self.useCase.healthKitAuthorization()
                    .subscribe()
                    .disposed(by: self.disposeBag)
                
                self.useCase.unReadChatting(roomID: self.roomId)
                    .subscribe { count in
                        self.unReadChat.onNext(count)
                    }
                    .disposed(by: self.disposeBag)
                
                if self.timerCount.value != 60 { return }
                self.useCase.timerStart()
                    .subscribe { time in
                        if time <= -1 {
                            self.gameOver.onNext(())
                            self.gameOverAction(time: 60)
                        } else {
                            self.timerCount.accept(time)
                        }
                    }
                    .disposed(by: self.timerBag)
                
                self.useCase.initVisitedLocation()
                    
            }
            .disposed(by: disposeBag)
        
        input.resetButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.useCase.getLocation()
                    .first()
                    .subscribe(onSuccess: { position in
                        guard let position = position else {return}
                        self.currentLocation.onNext(position)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.watchOthersLocationButtonTapped
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.watchOthersLocation(roomID: self.roomId)
                    .subscribe(onSuccess: { coordinate in
                        self.otherLocation.onNext(coordinate)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.exitButtonTapped
            .withUnretained(self)
            .subscribe { _ in
                self.leaveRoom()
            }
            .disposed(by: disposeBag)
        
        input.gameOverButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.leaveRoom()
            })
            .disposed(by: disposeBag)
        
        useCase.point()
            .bind(to: gamePoint)
            .disposed(by: disposeBag)
        
        input.toRoomButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.coordinator?.showMultiGameChatViewController(roomID: self.roomId)
            })
            .disposed(by: disposeBag)
        
        input.didEnterBackground
            .withUnretained(self)
            .subscribe(onNext: { _ in
                UserDefaults.standard.setValue(self.roomId, forKey: "roomID")
            })
            .disposed(by: disposeBag)
        
        Observable.of(
            input.exitButtonTapped,
            input.gameOverButtonTapped
        )
        .merge()
        .withUnretained(self)
        .subscribe(onNext: { _ in
            self.useCase.stopOberservingRoom(id: self.roomId)
        })
        .disposed(by: disposeBag)
    
    }
    
    private func leaveRoom() {
        useCase.leave(roomID: roomId)
        coordinator?.delegate?.didFinished(childCoordinator: coordinator!)
    }
    
    private func gameOverAction(time: Int) {
        useCase.healthKitStore(time: time)
        useCase.stopObserveLocation()
        timerStop()
    }
    
    private func timerStop() {
        useCase.timerStop()
        timerBag = DisposeBag()
    }
}
