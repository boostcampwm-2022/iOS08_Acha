//
//  LocationRepository.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import CoreLocation

protocol LocationRepository {
    
    /// location 얻는 레포지토리
    func getCurrentLocation() -> Observable<Coordinate>
    /// CLLocation 스탑 
    func stopObservingLocation()
}
