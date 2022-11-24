//
//  RecordMainViewRepository.swift
//  Acha
//
//  Created by 배남석 on 2022/11/23.
//

import Foundation
import RxSwift

protocol RecordRepository {
    func fetchMapData() -> Observable<[Map]>
    func fetchRecordData() -> Observable<[RecordViewRecord]>
}
