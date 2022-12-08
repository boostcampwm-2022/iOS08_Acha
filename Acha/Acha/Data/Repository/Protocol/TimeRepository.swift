//
//  TimeRepository.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift

protocol TimeRepository {
    
    /// 타이머 시작 ( 1 -> 2 -> 3 ... )
    func startTimer() -> Observable<Int>

    /// 특정 시간 타이머 맞춤 ( 0초 되면 종료 )
    func setTimer(time: Int) -> Observable<Int>
  
    /// 타이머 종료
    func stopTimer()
}
