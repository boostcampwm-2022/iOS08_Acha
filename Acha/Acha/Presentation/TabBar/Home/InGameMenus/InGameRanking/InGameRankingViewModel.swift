//
//  InGameRankingViewModel.swift
//  Acha
//
//  Created by 조승기 on 2022/11/21.
//

import Foundation
import RxSwift
import Firebase

class InGameRankingViewModel: BaseViewModel {
    struct Input {
        
    }
    struct Output {
        var rankings: Single<[InGameRanking]>
    }
    private let inGameUseCase: InGameUseCase
    var disposeBag = DisposeBag()
    
    init(inGameUseCase: InGameUseCase) {
        self.inGameUseCase = inGameUseCase
    }
    
    func transform(input: Input) -> Output {
        Output(rankings: inGameUseCase.fetchRanking())
    }
}
