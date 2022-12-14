//
//  RecordRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import RxSwift

protocol RecordRepository {
    func fetchAllRecords() -> Single<[Record]>
    func fetchRecordDataAtMapID(mapID: Int) -> Single<[Record]>
    func uploadNewRecord(record: Record)
    func recordCount() -> Single<Int>
    func healthKitAuthorization() -> Observable<Void>
    func healthKitWrite(_ data: HealthKitWriteData) -> Observable<Void>
    func healthKitRead() -> Observable<HealthKitReadData>
}
