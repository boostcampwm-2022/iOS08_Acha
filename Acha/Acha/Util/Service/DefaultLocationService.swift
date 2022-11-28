//
//  LocationService.swift
//  Acha
//
//  Created by 조승기 on 2022/11/24.
//

import Foundation
import RxSwift
import CoreLocation

class DefaultLocationService: NSObject, LocationService {
    private let locationManager: CLLocationManager
    private var disposeBag = DisposeBag()
    var authorizationStatus = PublishSubject<Bool>()
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func start() {
        getLocationUsagePermission()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func observeLocation() -> Observable<CLLocation> {
        return PublishSubject<CLLocation>.create({ observer in
            self.rx.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
                .subscribe(onNext: { locations in
                    guard let locations = locations[1] as? [CLLocation],
                          let currentLocation = locations.last else { return }
                    observer.onNext(currentLocation)
                }).disposed(by: self.disposeBag)
            return Disposables.create()
        })
    }
    
    func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension DefaultLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            authorizationStatus.onNext(true)
        case .restricted, .notDetermined:
            getLocationUsagePermission()
        case .denied:
            authorizationStatus.onNext(false)
        @unknown default:
            fatalError()
        }
    }
}
