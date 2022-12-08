//
//  MultiGameViewModel.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

struct MultiGameViewModel: BaseViewModel {
    
    var disposeBag: RxSwift.DisposeBag = .init()
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let resetButtonTapped: Observable<Void>
        let watchOthersLocationButtonTapped: Observable<Void>
        let exitButtonTapped: Observable<Void>
        let gameOverButtonTapped: Observable<Void>
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
    }
    
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
        let timeCount = PublishSubject<Int>()
        let visitedLocation = PublishSubject<Coordinate>()
        let gamePoint = PublishSubject<Int>()
        let movedDistance = PublishSubject<Double>()
        let playerDataFetcehd = PublishSubject<[MultiGamePlayerData]>()
        let currentLocation = PublishSubject<Coordinate>()
        let otherLocation = PublishSubject<Coordinate>()
        let gameOver = PublishSubject<Void>()
        input.viewDidAppear
            .subscribe { _ in
                useCase.timerStart()
                    .subscribe { time in
                        if time <= -1 {
                            gameOver.onNext(())
                            useCase.timerStop()
//                            gameOverAction(time: 60)
                        } else {
                            timeCount.onNext(time)
                        }
                    }
                    .disposed(by: disposeBag)
                
                useCase.getLocation()
                    .subscribe { location in
                        visitedLocation.onNext(location)
                        useCase.updateData(roomId: roomId)
                        movedDistance.onNext(useCase.movedDistance)
                    }
                    .disposed(by: disposeBag)
                
                useCase.observing(roomID: roomId)
                    .subscribe {
                        if $0.count >= 2 {
                            playerDataFetcehd.onNext($0)
//                            gameOverAction(time: 60)
                        } else {
                            gameOver.onNext(())
                        }
                    }
                    .disposed(by: disposeBag)
                    
            }
            .disposed(by: disposeBag)
        
        input.resetButtonTapped
            .subscribe(onNext: {
                useCase.getLocation()
                    .subscribe(onNext: { position in
                        currentLocation.onNext(position)
                        useCase.stopObserveLocation()
                    })
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.watchOthersLocationButtonTapped
            .subscribe { _ in
                useCase.watchOthersLocation(roomID: roomId)
                    .subscribe(onSuccess: { coordinate in
                        otherLocation.onNext(coordinate)
                    })
                    .disposed(by: disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.exitButtonTapped
            .subscribe { _ in
                leaveRoom()
            }
            .disposed(by: disposeBag)
        
        input.gameOverButtonTapped
            .subscribe(onNext: { _ in
                leaveRoom()
            })
            .disposed(by: disposeBag)
        
        visitedLocation
            .subscribe { _ in
            useCase.point()
                .subscribe { point in
                    gamePoint.onNext(point)
                }
                .disposed(by: disposeBag)
        }
        .disposed(by: disposeBag)
    
        return Output(
            time: timeCount.asDriver(onErrorJustReturn: -1),
            visitedLocation: visitedLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0)),
            gamePoint: gamePoint.asDriver(onErrorJustReturn: 0),
            movedDistance: movedDistance.asDriver(onErrorJustReturn: 0),
            playerDataFetched: playerDataFetcehd.asDriver(onErrorJustReturn: []),
            currentLocation: currentLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0)),
            otherLocation: otherLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0)),
            gameOver: gameOver.asDriver(onErrorJustReturn: ())
        )
    }
    
    private func leaveRoom() {
        useCase.leave(roomID: roomId)
        coordinator?.delegate?.didFinished(childCoordinator: coordinator!)
    }
    
    private func gameOverAction(time: Int) {
        useCase.healthKitStore(time: time)
        useCase.stopObserveLocation()
        useCase.timerStop()
    }
}
    