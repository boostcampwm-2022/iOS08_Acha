//
//  GameOverViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/17.
//

import Foundation
import RxSwift

final class GameOverViewModel: BaseViewModel {
    struct Input {
        var okButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    var disposeBag = DisposeBag()
    private let coordinator: SingleGameCoordinator
    let record: AchaRecord
    let mapName: String
    
    init(coordinator: SingleGameCoordinator, record: AchaRecord, mapName: String) {
        self.coordinator = coordinator
        self.record = record
        self.mapName = mapName
    }
    
    func transform(input: Input) -> Output {
        input.okButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.delegate?.didFinished(childCoordinator: self.coordinator)
            }).disposed(by: disposeBag)
        return Output()
    }
}
