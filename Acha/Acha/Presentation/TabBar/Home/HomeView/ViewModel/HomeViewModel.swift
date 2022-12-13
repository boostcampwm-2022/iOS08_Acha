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
        
        input.singleGameModeDidTap
            .subscribe { [weak self] _ in
                self?.coordinator?.connectSingleGameFlow()
            }
            .disposed(by: disposeBag)
        input.cameraDetectedSometing
            .distinctUntilChanged()
            .subscribe { [weak self] qrStringValue in
                guard let self = self else {return}
                self.useCase.enterRoom(id: qrStringValue)
                    .subscribe(onSuccess: { _ in
                        self.coordinator?.connectMultiGameFlow(gameID: qrStringValue)
                    }, onFailure: { error in
                        self.coordinator?.navigationController.showAlert(
                            title: "주의",
                            message: error.localizedDescription
                        )
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.makeRoomButtonDidTap
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.makeRoom()
                    .subscribe(onNext: { roomID in
                        self.coordinator?.connectMultiGameFlow(gameID: roomID)
                    }, onError: { _ in
                        self.coordinator?.navigationController.showAlert(
                            title: "주의",
                            message: "방 생성에 실패했습니다 😭😭😭"
                        )
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        let uuidDidPass = Observable<String>.create { [weak self] observer in
            guard let self = self else {return Disposables.create()}
            input.makeRoomButtonDidTap
                .subscribe { _ in
                    self.useCase.getUUID()
                        .subscribe { uuid in
                            observer.onNext(uuid)
                        }
                        .disposed(by: self.disposeBag)
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
        
        let didMultiGameModeDidTap = Observable<Void>.create { [weak self] observer in
            guard let self = self else {return Disposables.create()}
            input.multiGameModeDidTap
                .subscribe { _ in
                    observer.onNext(())
                }
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
        
        return Output(
            multiGameModeTapped: didMultiGameModeDidTap,
            uuidDidPass: uuidDidPass,
            roomEnterBehavior: input.enterOtherRoomButtonDidTap,
            qrInformationDetectedByCamera: uuidDidPass
        )
    }
}
