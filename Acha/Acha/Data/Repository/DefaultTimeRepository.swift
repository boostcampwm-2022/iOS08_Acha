//
//  DefaultTimeRepository.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift

struct DefaultTimeRepository: TimeRepository {
    
    private let timerService: TimerService
    
    init(timeService: TimerService) {
        self.timerService = timeService
    }
    
    func startTimer() -> Observable<Int> {
        return timerService.start()
    }
    
    func setTimer(time: Int) -> Observable<Int> {
        return startTimer()
            .map {
                let remainTime = time - $0
                if remainTime <= 0 { stopTimer() }
                return remainTime
            }
    }
    
    func stopTimer() {
        return timerService.stop()
    }
}
