//
//  MultiGameUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift

protocol MultiGameUseCase {
    
    func timerStart() -> Observable<Int>
    func timerStop()
}
