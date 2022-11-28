//
//  DefaultMapRepository.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import Foundation
import RxSwift

final class DefaultMapRepository: MapRepository {
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
    }
    func fetchAllMaps() -> Observable<[Map]> {
        realTimeDatabaseNetworkService.fetch(path: "mapList").asObservable()
    }
}
