//
//  MapBaseUseCase.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/28.
//

import RxSwift

protocol MapBaseUseCase {
    var user: BehaviorSubject<User> { get set }
    var userLocation: BehaviorSubject<Coordinate> { get set }
    
    func start()
    func stop()
    func isAvailableLocationAuthorization() -> Observable<(Bool, Coordinate?)>
}
