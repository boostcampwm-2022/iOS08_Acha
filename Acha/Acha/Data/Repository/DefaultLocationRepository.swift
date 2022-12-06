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
    
    func getCurrentLocation() -> Observable<CLLocation> {
        locationService.start()
        return locationService.userLocation
    }
    
    func stopObservingLocation() {
        locationService.stop()
    }
}
