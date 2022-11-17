//
//  HomeViewModel.swift
//  Acha
//
//  Created by 배남석 on 2022/11/15.
//

import Foundation
import RxSwift
import RxRelay
final class HomeViewModel {
    var coordinator: HomeCoordinator
    let singleGameTap = PublishRelay<Void>()
    let multiGameTap = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        bind()
    }
    
    private func bind() {
        singleGameTap
            .subscribe(onNext: {
                self.coordinator.connectSingleGameFlow()
            })
            .disposed(by: disposeBag)
        multiGameTap
            .subscribe(onNext: {
                print("multiGameTap")
                #warning("TODO : 멀티모드")
//                self.coordinator.showSelectViewController()
                self.coordinator.connectSingleGameFlow()
            })
            .disposed(by: disposeBag)
    }
}
