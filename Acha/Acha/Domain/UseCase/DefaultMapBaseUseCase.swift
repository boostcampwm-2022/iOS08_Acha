//
//  DefaultMapBaseUseCase.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/28.
//

import RxSwift

class DefaultMapBaseUseCase: MapBaseUseCase {
    
    private let locationService: LocationService
    private var disposeBag = DisposeBag()
    var userLocation = BehaviorSubject<Coordinate>(value: Coordinate(latitude: 37.0, longitude: 126.0))
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func start() {
        locationService.start()
        locationService.userLocation
            .asObserver()
            .skip(1)
            .map { Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .bind(to: self.userLocation)
            .disposed(by: disposeBag)
    }
    
    func stop() {
        locationService.stop()
    }
    
    func isAvailableLocationAuthorization() -> Observable<(Bool, Coordinate?)> {
        locationService.authorizationStatus
            .debug()
            .map { [weak self] status in
                if let self,
                   status,
                   let userLocation = try? self.userLocation.value() {
                    return (status, userLocation)
                } else {
                    return (status, nil)
                }
            }
    }
}
