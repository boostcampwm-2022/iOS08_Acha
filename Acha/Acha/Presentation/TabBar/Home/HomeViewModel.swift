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
                print("singleGameTap")
                self.coordinator.showSelectViewController()
            })
            .disposed(by: disposeBag)
        multiGameTap
            .subscribe(onNext: {
                print("multiGameTap")
                self.coordinator.showSelectViewController()
            })
            .disposed(by: disposeBag)
    }
}
