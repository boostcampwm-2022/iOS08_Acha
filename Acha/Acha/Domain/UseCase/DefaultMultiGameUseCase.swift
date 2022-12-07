//
//  DefaultMultiGameUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import RxRelay

final class DefaultMultiGameUseCase: MultiGameUseCase {
    
    private let gameRoomRepository: GameRoomRepository
    private let userRepository: UserRepository
    private let recordRepository: RecordRepository
    private let timeRepository: TimeRepository
    private let locationRepository: LocationRepository
    private let disposeBag = DisposeBag()
    
    var visitedLocation: Set<Coordinate> = []
    var previousPosition = Coordinate(latitude: 0, longitude: 0)
    var movedDistance: Double = 0
    var calorie: Int {
        return Int(movedDistance/100)
    }
    
    init(
        gameRoomRepository: GameRoomRepository,
        userRepository: UserRepository,
        recordRepository: RecordRepository,
        timeRepository: TimeRepository,
        locationRepository: LocationRepository
    ) {
        self.gameRoomRepository = gameRoomRepository
        self.userRepository = userRepository
        self.recordRepository = recordRepository
        self.timeRepository = timeRepository
        self.locationRepository = locationRepository
    }
    
    func timerStart() -> Observable<Int> {
        return timeRepository.setTimer(time: 60)
    }
    
    func timerStop() {
        timeRepository.stopTimer()
    }
    
    func getLocation() -> Observable<Coordinate> {
        return locationRepository.getCurrentLocation()
            .map { [weak self] location in
                self?.appendVisitedLocation(location)
                self?.distanceAppend(location)
                return location
            }
    }
    
    func point() -> Observable<Int> {
        return Observable<Int>.create { [weak self] observer in
            observer.onNext(self?.visitedLocation.count ?? 0)
            return Disposables.create()
        }
    }
    
    func updateData(roomId: String) {
        userRepository.fetchUserData()
            .subscribe(onSuccess: { [weak self] user in
                guard let self = self else {return}
                let playerData = MultiGamePlayerData(
                    id: user.id,
                    nickName: user.nickName,
                    currentLocation: self.previousPosition,
                    point: self.visitedLocation.count
                )
                let visitedLocation = self.visitedLocation.map { $0 }
                self.gameRoomRepository.updateMultiGamePlayer(
                    roomId: roomId,
                    data: playerData,
                    histroy: visitedLocation
                )
            })
            .disposed(by: disposeBag)
    }
    
    func healthKitStore(time: Int) {
        recordRepository.healthKitWrite(
            .init(distance: movedDistance,
                  diatanceTime: time,
                  calorie: calorie,
                  calorieTime: time)
        )
        .subscribe()
        .disposed(by: disposeBag)
    }
    
    func stopObserveLocation() {
        locationRepository.stopObservingLocation()
    }
    
    func observing(roomID: String) -> Observable<[MultiGamePlayerData]> {
        return gameRoomRepository.observingMultiGamePlayers(id: roomID)
            .map { $0.sorted { player1, player2 in
                player1.point > player2.point
            } }
    }
    
    private func distanceAppend(_ current: Coordinate) {
        let distance = previousPosition.distance(from: current)
        if distance <= 100 {
            movedDistance += distance
        }
        previousPosition = current
    }
    
    private func appendVisitedLocation(_ location: Coordinate) {
        var availiableToList = true
        for position in visitedLocation {
            if position.distance(from: location) < 5 {
                availiableToList = false
                break
            }
        }
        if availiableToList { visitedLocation.insert(location) }
    }
}
