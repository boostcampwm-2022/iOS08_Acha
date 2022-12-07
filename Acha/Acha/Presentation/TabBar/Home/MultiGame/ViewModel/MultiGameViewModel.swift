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
    }
    
    struct Output {
        let time: Driver<Int>
        let visitedLocation: Driver<Coordinate>
        let gamePoint: Driver<Int>
        let movedDistance: Driver<Double>
        let playerDataFetched: Driver<[MultiGamePlayerData]>
        let currentLocation: Driver<Coordinate>
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
        input.viewDidAppear
            .subscribe { _ in
                useCase.timerStart()
                    .subscribe { time in
                        if time <= -1 {
                            useCase.timerStop()
                            gameOverAction(time: 60)
                        }
                        else { timeCount.onNext(time) }
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
                    .subscribe { playerDataFetcehd.onNext($0) }
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
            currentLocation: currentLocation.asDriver(onErrorJustReturn: Coordinate(latitude: 0, longitude: 0))
        )
    }
    
    private func gameOverAction(time: Int) {
        useCase.healthKitStore(time: time)
        useCase.stopObserveLocation()
        self.coordinator?.navigationController.showAlert(title: "게임 종료", message: "종료 !!!")
//        self.coordinator?.delegate?.didFinished(childCoordinator: self.coordinator!)
    }
}
