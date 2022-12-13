//
// LocationService.swift
// Acha
//
// Created by 조승기 on 2022/11/24.
//

import Foundation
import RxSwift
import CoreLocation

final class DefaultLocationService: NSObject, LocationService {
    private let locationManager: CLLocationManager
    private var disposeBag = DisposeBag()
    
    var authorizationStatus = PublishSubject<Bool>()
    var userLocation = BehaviorSubject<CLLocation>(value: CLLocation(latitude: 37.0, longitude: 126.0))
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
    }
    
    func start() {
        getLocationUsagePermission()
        setUp()
        if locationManager.authorizationStatus == .authorizedAlways ||
            locationManager.authorizationStatus == .authorizedWhenInUse {
            startUserLocation()
        } else {
            getLocationUsagePermission()
        }
        observeLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    private func setUp() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
    }
    
    private func startUserLocation() {
        locationManager.startUpdatingLocation()
        if let location = locationManager.location {
            userLocation.onNext(location)
        }
        authorizationStatus.onNext(true)
    }
    
    private func observeLocation() {
        self.rx.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .subscribe(onNext: { [weak self] locations in
                guard let self,
                      let locations = locations[1] as? [CLLocation],
                      let currentLocation = locations.last else { return }
                self.userLocation.onNext(currentLocation)
            }).disposed(by: self.disposeBag)
    }
    
    private func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension DefaultLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startUserLocation()
        case .restricted, .notDetermined:
            getLocationUsagePermission()
        case .denied:
            authorizationStatus.onNext(false)
        @unknown default:
            fatalError()
        }
    }
}
