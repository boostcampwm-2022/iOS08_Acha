//
//  DefaultRecordRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import RxSwift

final class DefaultRecordRepository: RecordRepository {
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
    }
    
    func fetchAllRecords() -> Single<[Record]> {
        realTimeDatabaseNetworkService.fetch(path: FirebasePath.record)
            .map { (recordDTOs: [RecordDTO]) in
                return recordDTOs.map { $0.toDomain() }
            }
    }
}
