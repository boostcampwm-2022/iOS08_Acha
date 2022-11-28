//
//  TimerServiceProtocol.swift
//  Acha
//
//  Created by 조승기 on 2022/11/23.
//

import Foundation
import RxSwift

protocol TimerServiceProtocol {
    var disposeBag: DisposeBag { get set }
    
    func start() -> Observable<Int>
    func start(until: Int) -> Observable<Void>
    func stop()
}
