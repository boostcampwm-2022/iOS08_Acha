//
//  RecordRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import RxSwift

protocol RecordRepository {
    func fetchAllRecords() -> Single<[Record]>
}
