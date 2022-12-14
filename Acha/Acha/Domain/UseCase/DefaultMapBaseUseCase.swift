//
//  DefaultMapBaseUseCase.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/28.
//

import RxSwift

class DefaultMapBaseUseCase: MapBaseUseCase {
    
    private let locationService: LocationService
    let userRepository: UserRepository
    
    var user = BehaviorSubject<User>(value: User())
    var userLocation = BehaviorSubject<Coordinate>(value: Coordinate(latitude: 37.0, longitude: 126.0))
    private var disposeBag = DisposeBag()
    
    init(locationService: LocationService,
         userRepository: UserRepository) {
        self.locationService = locationService
        self.userRepository = userRepository
    }
    
    func start() {
        locationService.start()
        locationService.userLocation
            .map { Coordinate(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
            .bind(to: self.userLocation)
            .disposed(by: disposeBag)
        
        userRepository.fetchUserData()
            .subscribe(onSuccess: { [weak self] user in
                guard let self else { return }
                self.user.onNext(user)
            }).disposed(by: disposeBag)
    }
    
    func stop() {
        locationService.stop()
    }
    
    func isAvailableLocationAuthorization() -> Observable<(Bool, Coordinate?)> {
        locationService.authorizationStatus
            .delay(.microseconds(1), scheduler: MainScheduler.instance)
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
