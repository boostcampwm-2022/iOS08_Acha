//
//  InGameRecordViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/21.
//

import Foundation
import RxSwift
import RxRelay
import Firebase

final class InGameRecordViewModel: BaseViewModel {
    
    struct Input {
        
    }
    
    struct Output {
        var inGameRecord: PublishSubject<[InGameRecord]>
    }
    
    private let inGameUseCase: InGameUseCase
    var disposeBag = DisposeBag()
    
    init(inGameUseCase: InGameUseCase) {
        self.inGameUseCase = inGameUseCase
    }
    
    func transform(input: Input) -> Output {
        inGameUseCase.fetchRecord()
        return Output(inGameRecord: inGameUseCase.inGameRecord)
    }
}
