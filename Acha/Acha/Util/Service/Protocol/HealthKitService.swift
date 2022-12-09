//
//  HealthKitService.swift
//  Acha
//
//  Created by hong on 2022/12/01.
//

import Foundation
import RxSwift

protocol HealthKitService {
    /// 헬스 킷에 값 저장 가능
    func write(type: DefaultHealthKitServiceType) -> Observable<Void>
    /// 헬스 킷에서 최근 값 가져 옴
    func read(type: DefaultHealthKitServiceType) -> Observable<Double>
    /// 헬스 인증 요청
    func authorization() -> Observable<Void>
}
