//
//  GameOverViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/17.
//

import Foundation
import RxSwift
import Firebase

final class GameOverViewModel: BaseViewModel {
    struct Input {
        var okButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    private let coordinator: SingleGameCoordinator
    var disposeBag = DisposeBag()
    let ref: DatabaseReference!
    let record: AchaRecord
    let mapName: String
    let isCompleted: Bool
    
    init(coordinator: SingleGameCoordinator,
         record: AchaRecord,
         mapName: String,
         isCompleted: Bool
    ) {
        self.coordinator = coordinator
        self.record = record
        self.mapName = mapName
        self.isCompleted = isCompleted
        self.ref = Database.database().reference()
    }
    
    func transform(input: Input) -> Output {
        input.okButtonTapped
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.coordinator.delegate?.didFinished(childCoordinator: self.coordinator)
            }).disposed(by: disposeBag)
        return Output()
    }
    
    private func upload() {
        #warning("파이어스토어가 완료된 후 다시하겠습니다.")
    }
}
