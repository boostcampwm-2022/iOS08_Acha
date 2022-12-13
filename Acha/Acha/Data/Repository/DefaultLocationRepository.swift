//
//  DefaultLocationRepository.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import CoreLocation

struct DefaultLocationRepository: LocationRepository {
    
    private let locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func getCurrentLocation() -> Observable<Coordinate> {
        locationService.start()
        return locationService.userLocation
            .skip(1)
            .map { return Coordinate(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude
            ) }
    }
    
    func stopObservingLocation() {
        locationService.stop()
    }
}
