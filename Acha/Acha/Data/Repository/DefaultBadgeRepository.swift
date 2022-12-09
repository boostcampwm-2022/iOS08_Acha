//
//  DefaultBadgeRepository.swift
//  Acha
//
//  Created by  sangyeon on 2022/12/01.
//

import RxSwift

final class DefaultBadgeRepository: BadgeRepository {
    private let realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
    }
    
    func fetchAllBadges() -> Single<[Badge]> {
        realTimeDatabaseNetworkService.fetch(type: FirebaseRealtimeType.badge)
            .map { (badgeDTOs: [BadgeDTO]) in
                badgeDTOs.map { $0.toDomain() }
            }
    }
    
    func fetchSomeBadges(ids: [Int]) -> Single<[Badge]> {
        fetchAllBadges()
            .map { (badges: [Badge]) -> [Badge] in
                return badges.filter { ids.contains($0.id) }
            }
    }
}
