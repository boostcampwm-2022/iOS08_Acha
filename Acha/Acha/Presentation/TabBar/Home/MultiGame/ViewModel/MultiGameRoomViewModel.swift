//
//  MultiGameRoomViewModel.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift
import RxRelay

final class MultiGameRoomViewModel: BaseViewModel {
    var disposeBag: RxSwift.DisposeBag = .init()

    struct Input {
        let viewWillAppear: Observable<Void>
        let viewDidAppear: Observable<Void>
    }
    
    struct Output {
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

        input.viewDidAppear
            .subscribe { [weak self] _ in
                print("didAppear")
            }
            .disposed(by: bag)
        disposeBag = bag
        return Output()
    }
}
