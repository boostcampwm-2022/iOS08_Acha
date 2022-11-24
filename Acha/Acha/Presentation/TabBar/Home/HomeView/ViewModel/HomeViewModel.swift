//
//  HomeViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import Foundation
import RxSwift
import RxRelay

final class HomeViewModel: BaseViewModel {

    struct Input {
        let singleGameModeDidTap: Observable<Void>
        let multiGameModeDidTap: Observable<Void>
        let makeRoomButtonDidTap: Observable<Void>
        let enterOtherRoomButtonDidTap: Observable<Void>
        let cameraDetectedSometing: Observable<String>
    }
    
    struct Output {
        let multiGameModeTapped: Observable<Void>
        let uuidDidPass: Observable<String>
        let roomEnterBehavior: Observable<Void>
        let qrInformationDetectedByCamera: Observable<String>
    }
    
    var disposeBag = DisposeBag()
    private weak var coordinator: HomeCoordinator?
    private let useCase: HomeUseCase
    
    init(
        coordinator: HomeCoordinator,
        useCase: HomeUseCase
    ) {
        self.useCase = useCase
        self.coordinator = coordinator
    }
    
    public func transform(input: Input) -> Output {
        
        let bag = DisposeBag()
        
        input.singleGameModeDidTap
            .subscribe { [weak self] _ in
                self?.coordinator?.connectSingleGameFlow()
            }
            .disposed(by: bag)
        input.cameraDetectedSometing
            .distinctUntilChanged()
            .subscribe { [weak self] qrStirngValue in
                FBRealTimeDB().enter(.user(id: "AZCgPBWrL7hqGFsfWDXBqeYxyrU2", data: nil), .room(id: qrStirngValue, data: nil))
                self?.coordinator?.connectMultiGameFlow(gameID: qrStirngValue)
            }
            .disposed(by: bag)
        
        input.makeRoomButtonDidTap
            .subscribe { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.coordinator?.connectMultiGameFlow(gameID: strongSelf.useCase.makeRoomID())
            }
            .disposed(by: bag)
        
        let uuidDidPass = Observable<String>.create { observer in
            input.makeRoomButtonDidTap
                .subscribe { [weak self] _ in
                    self?.useCase.getUUID()
                        .subscribe { uuid in
                            observer.onNext(uuid)
                        }
                        .disposed(by: bag)
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        let didMultiGameModeDidTap = Observable<Void>.create { observer in
            input.multiGameModeDidTap
                .subscribe { _ in
                    observer.onNext(())
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        disposeBag = bag
        
        return Output(
            multiGameModeTapped: didMultiGameModeDidTap,
            uuidDidPass: uuidDidPass,
            roomEnterBehavior: input.enterOtherRoomButtonDidTap, 
            qrInformationDetectedByCamera: uuidDidPass
        )
    }
}
