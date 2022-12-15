//
//  DefaultTimerService.swift
//  Acha
//
//  Created by 조승기 on 2022/11/23.
//

import Foundation
import RxSwift

final class DefaultTimerService: TimerService {
    var disposeBag = DisposeBag()
    
    func start() -> Observable<Int> {
        Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .map { $0 + 1 }
    }
    
    func start(until: Int) -> Observable<Void> {
        Observable<Int>
            .timer(.seconds(until), scheduler: MainScheduler.asyncInstance)
            .map { _ in }
    }
    
    func stop() {
        disposeBag = DisposeBag()
    }
}
