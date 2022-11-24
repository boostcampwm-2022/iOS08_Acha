//
//  MultiGameRoomViewModel.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

final class MultiGameRoomViewModel: BaseViewModel {
    var disposeBag: RxSwift.DisposeBag = .init()

    struct Input {
        let viewWillAppear: Observable<Void>
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
        input.viewWillAppear.subscribe { [weak self] _ in
            self?.useCase.make(roomID: self?.roomID ?? "")
//            self?.getData()
        }
        .disposed(by: disposeBag)
        return Output()
    }
    
//    private func getData() {
//        self.useCase.get(roomID: self.roomID)
//            .subscribe(onError: { error in
//                print(error)
//            })
//            .disposed(by: disposeBag)
//    }
}
