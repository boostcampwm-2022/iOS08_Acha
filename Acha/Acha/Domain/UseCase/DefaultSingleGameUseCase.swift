//
//  DefaultSingleGameUseCase.swift
//  Acha
//
//  Created by 조승기 on 2022/11/23.
//

import Foundation
import RxSwift
import CoreLocation

class DefaultSingleGameUseCase: SingleGameUseCase {
    private let locationService: LocationService
    private var disposeBag = DisposeBag()
    
    var tapTimer: TimerServiceProtocol
    var runningTimer: TimerServiceProtocol
    var map: Map
    
    var ishideGameOverButton = BehaviorSubject<Bool>(value: true)
    var previousCoordinate: Coordinate?
    var currentLocation = PublishSubject<Coordinate>()
    var runningTime = BehaviorSubject<Int>(value: 0)
    var runningDistance = BehaviorSubject<Double>(value: 0)
    
    var wentLocations = PublishSubject<[Coordinate]>()
    var visitLocations = PublishSubject<[Coordinate]>()
    var tooFarFromLocaiton = BehaviorSubject<Bool>(value: false)
    var visitedMapIndex = BehaviorSubject<Set<Int>>(value: [])
    var isGameOver = PublishSubject<Void>()
    
    init(map: Map,
         tapTimer: TimerServiceProtocol,
         runningTimer: TimerServiceProtocol,
         locationService: LocationService
    ) {
        self.tapTimer = tapTimer
        self.runningTimer = runningTimer
        self.locationService = locationService
        self.map = map
    }
    
    func startRunning() {
        startGameOverTimer()
        locationService.start()
        
        locationService.observeLocation()
            .subscribe(onNext: { [weak self] location in
                guard let self,
                      let previousCoordinate = self.previousCoordinate,
                      let distance = try? self.runningDistance.value(),
                      !distance.isNaN else { return }
                let currentCoordinate = Coordinate(latitude: location.coordinate.latitude,
                                                   longitude: location.coordinate.longitude)
                
                self.runningDistance.onNext(distance + previousCoordinate.distance(from: currentCoordinate))
                self.wentLocations.onNext([previousCoordinate, currentCoordinate])
                self.previousCoordinate = currentCoordinate
                self.checkVisitLocation(currentCoordinate: currentCoordinate)
                self.checkTooFar(currentCoordinate: currentCoordinate)
            })
            .disposed(by: disposeBag)
        
        visitedMapIndex
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }
                if index.count > Int(Double(self.map.coordinates.count) * 0.95) {
                    self.isGameOver.onNext(())
                }
            }).disposed(by: disposeBag)
    }
    
    private func checkVisitLocation(currentCoordinate: Coordinate) {
        let inBoundLocations = map.coordinates.enumerated().filter { (_, coordinate) in
            coordinate.distance(from: currentCoordinate) < 5
        }
        
        guard var visitedMapIndex = try? visitedMapIndex.value() else { return }
        inBoundLocations.forEach { visitedMapIndex.insert($0.offset) }
        self.visitedMapIndex.onNext(visitedMapIndex)
        
        guard inBoundLocations.count >= 2 else { return }
        visitLocations.onNext(inBoundLocations.map { $0.element })
    }
    
    private func checkTooFar(currentCoordinate: Coordinate) {
        let nearestDistance = map.coordinates.map { $0.distance(from: currentCoordinate) }.min() ?? 0
        tooFarFromLocaiton.onNext(nearestDistance > 10)
    }
    
    func startGameOverTimer() {
        ishideGameOverButton.onNext(false)
        tapTimer.start(until: 3)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.ishideGameOverButton.onNext(true)
            })
            .disposed(by: tapTimer.disposeBag)
    }
    
    func startRunningTimer() {
        runningTimer.start()
            .subscribe(onNext: { [weak self] time in
                guard let self else { return }
                self.runningTime.onNext(time)
            })
            .disposed(by: runningTimer.disposeBag)
    }
    
    func stopRunningTimer() {
        runningTimer.stop()
    }
    
}
