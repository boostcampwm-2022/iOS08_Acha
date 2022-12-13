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
    }
    
    struct Output {
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
    let timerCount = BehaviorRelay(value: 60)
    
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
        let visitedLocation = PublishSubject<Coordinate>()
        let gamePoint = PublishSubject<Int>()
        let movedDistance = PublishSubject<Double>()
        let playerDataFetcehd = PublishSubject<[MultiGamePlayerData]>()
        let currentLocation = PublishSubject<Coordinate>()
        let otherLocation = PublishSubject<Coordinate>()
        let gameOver = PublishSubject<Void>()
        let unReadChat = PublishSubject<Int>()
        
        useCase.unReadsCount
            .bind(to: unReadChat)
            .disposed(by: disposeBag)
        
        useCase.inGamePlayersData
            .bind(to: playerDataFetcehd)
            .disposed(by: disposeBag)
        
        useCase.currentRoomPlayerData
            .withUnretained(self)
            .subscribe(onNext: { _, roomUsers in
                if roomUsers.count < 2 {
                    self.gameOverAction(time: 60)
                    gameOver.onNext(())
                }
            })
            .disposed(by: disposeBag)
        
        input.viewDidAppear
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                
                self.useCase.getLocation()
                    .subscribe { location in
                        visitedLocation.onNext(location)
                        self.useCase.updateData(roomId: self.roomId)
                        movedDistance.onNext(self.useCase.movedDistance)
                    }
                    .disposed(by: self.disposeBag)
                
                self.useCase.observing(roomID: self.roomId)
                
                self.useCase.healthKitAuthorization()
                    .subscribe()
                    .disposed(by: self.disposeBag)
                
                
                if self.timerCount.value != 60 {
                    return
                }
                self.useCase.timerStart()
                    .subscribe { time in
                        if time <= -1 {
                            gameOver.onNext(())
                            self.gameOverAction(time: 60)
                        } else {
                            self.timerCount.accept(time)
                        }
                    }
                    .disposed(by: self.timerBag)
                    
            }
            .disposed(by: disposeBag)
        
        input.resetButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.useCase.getLocation()
                    .subscribe(onNext: { position in
                        currentLocation.onNext(position)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.watchOthersLocationButtonTapped
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.watchOthersLocation(roomID: self.roomId)
                    .subscribe(onSuccess: { coordinate in
                        otherLocation.onNext(coordinate)
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
        
        visitedLocation
            .withUnretained(self)
            .subscribe { _ in
                self.useCase.point()
                .subscribe { point in
                    gamePoint.onNext(point)
                }
                .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
        
        input.toRoomButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.coordinator?.showMultiGameChatViewController(roomID: self.roomId)
            })
            .disposed(by: disposeBag)
        
        Observable.of(input.exitButtonTapped, input.gameOverButtonTapped, input.viewWillDisappear)
            .merge()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.useCase.stopOberservingRoom(id: self.roomId)
            })
            .disposed(by: disposeBag)
    
        return Output(
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
