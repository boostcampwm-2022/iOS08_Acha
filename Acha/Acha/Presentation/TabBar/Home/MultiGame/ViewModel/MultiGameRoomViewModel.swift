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
        let viewWillDisappear: Observable<Void>
        let didEnterBackground: Observable<Void>

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
        let dataFetched = Observable<[RoomUser]>.create { [weak self] observer in
            input.viewDidAppear.subscribe { _ in
                guard let self = self else {return}
                self.useCase.observing(roomID: self.roomID)
                    .subscribe(onNext: { roomUsers in
                        guard let roomUsers = roomUsers else {
                            self.useCase.removeObserver(roomID: self.roomID)
                            self.coordinator?.showMultiGameViewController(roomID: self.roomID)
                            return
                        }
                        observer.onNext(roomUsers)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: self!.disposeBag)
            return Disposables.create()
        }
//        UIApplication.rx.applicationWillTerminate
//            .subscribe(onNext: { [weak self] in
//                guard let self = self else {retunr}
//                DefaultRealtimeDatabaseNetworkService().terminateGet(type: .room(id: self.roomID), id: self.roomID)
//            })
//            .disposed(by: disposeBag)
        
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
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.didEnterBackground
            .withUnretained(self)
            .subscribe(onNext: { _ in
                UserDefaults.standard.setValue(self.roomID, forKey: "roomID")
            })
            .disposed(by: disposeBag)
            

        Observable.of(
            input.exitButtonTapped,
            input.viewWillDisappear
        )
        .merge()
        .withUnretained(self)
        .subscribe(onNext: { _ in
            self.useCase.removeObserver(roomID: self.roomID)
        })
        .disposed(by: disposeBag)

        
        input.exitButtonTapped
            .withUnretained(self)
            .subscribe { _ in
                self.useCase.leave(roomID: self.roomID)
                self.coordinator?.delegate?.didFinished(childCoordinator: self.coordinator!)
            }
            .disposed(by: disposeBag)
        
        return Output(dataFetched: dataFetched)
    }
}
