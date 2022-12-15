//
//  InGameUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/29.
//

import Foundation
import RxSwift

protocol InGameUseCase {
    var inGameRecord: PublishSubject<[InGameRecord]> { get set }
    
    func fetchRecord()
    func fetchRanking() -> Single<[InGameRanking]>
}
