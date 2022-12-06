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
    }
    
    struct Output {
        let time: Driver<Int>
        let visitedLocation: Driver<CLLocation>
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
        let visitedLocation = PublishSubject<CLLocation>()
        input.viewDidAppear
            .subscribe { _ in
                useCase.timerStart()
                    .subscribe { time in
                        timeCount.onNext(time)
                    }
                    .disposed(by: disposeBag)
                
                useCase.getLocation()
                    .subscribe { location in
                        visitedLocation.onNext(location)
                    }
                    .disposed(by: disposeBag)
                    
            }
            .disposed(by: disposeBag)
        
        return Output(
            time: timeCount.asDriver(onErrorJustReturn: -1),
            visitedLocation: visitedLocation.asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
        )
    }
}
