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
    private let useCase: HomeUseCaseProtocol
    
    init(
        coordinator: HomeCoordinator,
        useCase: HomeUseCaseProtocol
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
            .subscribe { [weak self] qrStringValue in
                guard let self = self else {return}
                self.useCase.enterRoom(id: qrStringValue)
                    .subscribe(onSuccess: { _ in
                        self.coordinator?.connectMultiGameFlow(gameID: qrStringValue)
                    }, onError: { _ in
                        print("입장실패")
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: bag)
        
        input.makeRoomButtonDidTap
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.makeRoom()
                    .subscribe(onNext: { roomID in
                        self.coordinator?.connectMultiGameFlow(gameID: roomID)
                    }, onError: { _ in
                        print("룸 생성 실패")
                    })
                    .disposed(by: self.disposeBag)
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
