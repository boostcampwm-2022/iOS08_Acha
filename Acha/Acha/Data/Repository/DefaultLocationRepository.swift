//
//  DefaultLocationRepository.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import CoreLocation

struct DefaultLocationRepository {
    
    private let locationService: LocationService
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func getCurrentLocation() -> Observable<CLLocation> {
        return locationService.userLocation.asObserver()
    }
    
    func stopObservingLocation() {
        locationService.stop()
    }
}
