//
//  DefaultInGameUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/29.
//

import Foundation
import RxSwift

class DefaultInGameUseCase: InGameUseCase {
    private let recordRepository: RecordRepository
    private let mapID: Int
    
    init(mapID: Int,
         recordRepository: RecordRepository
    ) {
        self.mapID = mapID
        self.recordRepository = recordRepository
    }
    
    func fetchRecord() -> Single<[InGameRecord]> {
        recordRepository.fetchAllRecords()
            .map { $0.filter { $0.mapID == self.mapID && $0.isCompleted } }
            .map { records in
                records.map { InGameRecord(id: $0.id,
                                         time: $0.time,
                                         userName: $0.userID,
                                         date: $0.createdAt.convertToDateFormat(format: "yyyy-MM-dd"))
            }.sorted { $0.date > $1.date}
            }
        
    }
    
    func fetchRanking() -> Single<[InGameRanking]> {
        recordRepository
            .fetchAllRecords()
            .map { $0.filter { $0.mapID == self.mapID && $0.isCompleted} }
            .map { records in
                records.map { InGameRanking(time: $0.time,
                                          userName: $0.userID,
                                          date: $0.createdAt.convertToDateFormat(format: "yyyy-MM-dd"))
            }.sorted { $0.time < $1.time }
            }
    }
}
