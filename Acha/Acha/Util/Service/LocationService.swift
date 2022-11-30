//
//  LocationService.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import Foundation
import RxSwift
import CoreLocation

protocol LocationService {
    var authorizationStatus: PublishSubject<Bool> { get set }
    func start()
    func stop()
    func observeLocation() -> Observable<CLLocation>
    func getLocationUsagePermission()
    
}
