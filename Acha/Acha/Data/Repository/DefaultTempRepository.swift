//
//  DefaultRecordMapViewRepository.swift
//  Acha
//
//  Created by 배남석 on 2022/11/23.
//

import Foundation
import RxSwift

final class DefaultTempRepository: TempRepository {
    var tempDBNetwork: TempDBNetwork
    
    init(tempDBNetwork: TempDBNetwork) {
        self.tempDBNetwork = tempDBNetwork
    }
    
    func fetchMapData() -> Observable<[Map]> {
        return tempDBNetwork.fetchData(path: "mapList").map { data in
            guard let map = try? JSONDecoder().decode([Map].self, from: data) else { return [] }
            return map
        }
    }
    
    func fetchRecordData() -> Observable<[Record]> {
        return tempDBNetwork.fetchData(path: "record").map { data in
            guard let records = try? JSONDecoder().decode([Record].self, from: data) else { return [] }
            return records
        }
    }
}
