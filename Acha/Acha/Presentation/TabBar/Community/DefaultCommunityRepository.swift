//
//  CommunityRepository.swift
//  Acha
//
//  Created by 배남석 on 2022/11/30.
//

import Foundation

final class DefaultCommunityRepository: CommunityRepository {
    var realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService
    
    init(realTimeDatabaseNetworkService: RealtimeDatabaseNetworkService) {
        self.realTimeDatabaseNetworkService = realTimeDatabaseNetworkService
    }
}
