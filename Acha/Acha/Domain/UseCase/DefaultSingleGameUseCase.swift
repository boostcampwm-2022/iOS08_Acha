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
    var gameOverInformation = PublishSubject<(Record, String)>()
    
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
        startRunningTimer()
        locationService.start()
        
        locationService.observeLocation()
            .subscribe(onNext: { [weak self] location in
                guard let self,
                      let distance = try? self.runningDistance.value(),
                      let previousCoordinate = self.previousCoordinate else {
                    self?.previousCoordinate = Coordinate(latitude: location.coordinate.latitude,
                                                         longitude: location.coordinate.longitude)
                    return
                }
                
                let currentCoordinate = Coordinate(latitude: location.coordinate.latitude,
                                                   longitude: location.coordinate.longitude)
                
                let currentDistance = previousCoordinate.distance(from: currentCoordinate)
                guard !currentDistance.isNaN else { return }
                
                self.runningDistance.onNext(distance + currentDistance)
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
                    self.emitGameOverInformation(isCompleted: true)
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
    
    func gameOverButtonTapped() {
        emitGameOverInformation(isCompleted: false)
    }
    
    private func emitGameOverInformation(isCompleted: Bool) {
        let observable = Observable
            .combineLatest(runningTime,
                           runningDistance,
                           resultSelector: { [weak self] (time, distance) in
                    guard let self else { return }
                    let createdAt = Date().convertToStringFormat(format: "yyyy-MM-dd")
                    
                    let kcal = Int(0.1128333333*Double(time))
                    let record = Record(id: 0,
                                        mapID: self.map.mapID,
                                        userID: "마끼",
                                        calorie: kcal,
                                        distance: Int(distance),
                                        time: time,
                                        isSingleMode: true,
                                        isCompleted: isCompleted,
                                        createdAt: createdAt)
                self.gameOverInformation.onNext((record, self.map.name))
            })
        
        var trashBag = DisposeBag()
        observable
            .subscribe(onNext: { })
            .disposed(by: trashBag)
        trashBag = DisposeBag()
    }
    
}
