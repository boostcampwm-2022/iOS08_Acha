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

final class MultiGameViewModel {

    var disposeBag: RxSwift.DisposeBag = .init()
    var timerBag = DisposeBag()
    
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
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.timerStart()
                    .subscribe { time in
                        if time <= -1 {
                            gameOver.onNext(())
                            self.gameOverAction(time: 60)
                        } else {
                            timeCount.onNext(time)
                        }
                    }
                    .disposed(by: self.timerBag)
                
                self.useCase.getLocation()
                    .subscribe { location in
                        visitedLocation.onNext(location)
                        self.useCase.updateData(roomId: self.roomId)
                        movedDistance.onNext(self.useCase.movedDistance)
                    }
                    .disposed(by: self.disposeBag)
                
                self.useCase.observing(roomID: self.roomId)
                    .subscribe { players in
                        if players.count >= 2 {
                            playerDataFetcehd.onNext(players)
                        } else {
                            gameOver.onNext(())
                            self.gameOverAction(time: 60)
                        }
                    }
                    .disposed(by: self.disposeBag)
                
                self.useCase.healthKitAuthorization()
                    .subscribe()
                    .disposed(by: self.disposeBag)
                    
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
        timerStop()
    }
    
    private func timerStop() {
        useCase.timerStop()
        timerBag = DisposeBag()
    }
}
