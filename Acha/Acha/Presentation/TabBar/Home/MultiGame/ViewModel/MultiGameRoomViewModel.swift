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
        let viewWillAppear: Observable<Void>
        let roomDataChanged: Observable<Void>
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
        input.viewWillAppear.subscribe { [weak self] _ in
            self?.useCase.make(roomID: self?.roomID ?? "")
        }
        .disposed(by: disposeBag)
        
        let dataFetched = Observable<[RoomUser]>.create { observer in
            input.roomDataChanged
                .subscribe { [weak self] _ in
                    self?.useCase.get(roomID: self?.roomID ?? "")
                        .subscribe(onNext: { roomUser in
                            print(roomUser)
                            observer.onNext(roomUser)
                        })
                        .disposed(by: bag)
                }
                .disposed(by: bag)
            return Disposables.create()
        }
        
        disposeBag = bag
        return Output(dataFetched: dataFetched)
    }
}
