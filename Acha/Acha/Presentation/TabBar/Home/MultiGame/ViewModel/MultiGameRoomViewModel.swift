//
//  MultiGameRoomViewModel.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseDatabase

final class MultiGameRoomViewModel: BaseViewModel {
    var disposeBag: RxSwift.DisposeBag = .init()

    struct Input {
        let viewDidAppear: Observable<Void>
        let exitButtonTapped: Observable<Void>
        let gameStartButtonTapped: Observable<Void>
    }
    
    struct Output {
        let dataFetched: Observable<[RoomUser]>
    }
    
    private weak var coordinator: MultiGameCoordinatorProtocol?
    private let useCase: MultiGameRoomUseCase
    private let roomID: String
    
    init(
        coordinator: MultiGameCoordinatorProtocol,
        useCase: MultiGameRoomUseCase,
        roomID: String
    ) {
        self.coordinator = coordinator
        self.useCase = useCase
        self.roomID = roomID
    }
    
    func transform(input: Input) -> Output {
        let bag = disposeBag
        let dataFetched = Observable<[RoomUser]>.create { observer in
            input.viewDidAppear.subscribe { [weak self] _ in
                self?.useCase.observing(roomID: self?.roomID ?? "")
                    .subscribe(onNext: { roomUsers in
                        observer.onNext(roomUsers)
                    })
                    .disposed(by: bag)
            }
            .disposed(by: bag)
            return Disposables.create()
        }
        
        input.gameStartButtonTapped
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.isGameAvailable(roomID: self.roomID)
                    .subscribe { _ in
                        self.useCase.startGame(roomID: self.roomID)
                        self.coordinator?.showMultiGameViewController(roomID: self.roomID)
                    } onError: { error in
                        self.coordinator?.navigationController.showAlert(
                            title: "주의",
                            message: error.localizedDescription
                        )
                    }
                    .disposed(by: bag)
            }
            .disposed(by: bag)
            
        input.exitButtonTapped
            .subscribe { [weak self] _ in
                guard let self = self else {return}
                self.useCase.leave(roomID: self.roomID)
                self.useCase.removeObserver(roomID: self.roomID)
                self.coordinator?.popSelfFromNavigatonController()
            }
            .disposed(by: bag)
        
        disposeBag = bag
        return Output(dataFetched: dataFetched)
    }
}
