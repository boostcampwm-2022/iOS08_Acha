//
//  DefaultRecordMapViewRepository.swift
//  Acha
//
//  Created by 배남석 on 2022/11/23.
//

import Foundation
import RxSwift

final class DefaultRecordRepository: RecordRepository {
    var realtimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    
    init(realtimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realtimeDatabaseNetworkService = realtimeDatabaseNetworkService
    }
    
    func fetchMapData() -> Observable<[Map]> {
        return realtimeDatabaseNetworkService.fetchData(path: "mapList").map { data in
            guard let map = try? JSONDecoder().decode([Map].self, from: data) else { return [] }
            return map
        }
    }
    
    func fetchRecordData() -> Observable<[RecordViewRecord]> {
        return realtimeDatabaseNetworkService.fetchData(path: "record").map { data in
            guard let records = try? JSONDecoder().decode([RecordViewRecord].self, from: data) else { return [] }
            return records
        }
    }
}
