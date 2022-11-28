//
//  DefaultSelectMapUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import Foundation

class DefaultSelectMapUseCase: SelectMapUseCase {
    private let locationService: LocationService
    private let mapRepository: MapRepository
    
    init(locationService: LocationService, mapRepository: MapRepository) {
        self.locationService = locationService
        self.mapRepository = mapRepository
    }
    
    func start() {
        mapRepository.fetchAllMaps()
    }
}
