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
        
    }
    
    struct Output {
        
    }
    
    var disposeBag = DisposeBag()
    private let coordinator: SingleGameCoordinator
    let record: AchaRecord
    
    init(coordinator: SingleGameCoordinator, record: AchaRecord) {
        self.coordinator = coordinator
        self.record = record
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
