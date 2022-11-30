//
// DefaultMapRepository.swift
// Acha
//
// Created by 조승기 on 2022/11/27.
//

import RxSwift

final class DefaultMapRepository: MapRepository {
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
    }
    
    func fetchAllMaps() -> Single<[Map]> {
        realTimeDatabaseNetworkService.fetch(type: FirebaseRealtimeType.mapList(id: nil))
    }
}
