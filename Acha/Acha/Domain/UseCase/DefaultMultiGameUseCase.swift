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
    
    enum GameRoomError: Error {
        case dataNotFetched
        case cantProceedThisGame
    }
    
    private let gameRoomRepository: GameRoomRepository
    private let userRepository: UserRepository
    private let recordRepository: RecordRepository
    private let timeRepository: TimeRepository
    private let locationRepository: LocationRepository
    private let disposeBag = DisposeBag()
    
    var visitedLocation: Set<Coordinate> = []
    private var previousPosition = Coordinate(latitude: 0, longitude: 0)
    var movedDistance: Double = 0
    private var calorie: Int {
        return Int(movedDistance/100)
    }
    private var watchOtherLocationIndex = 0
    
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
    
    func healthKitAuthorization() -> Observable<Void> {
        return recordRepository.healthKitAuthorization()
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
    }
    
    func watchOthersLocation(roomID: String) -> Single<Coordinate> {
        return gameRoomRepository.fetchRoomData(id: roomID)
            .map { $0.gameInformation ?? [] }
            .map { $0.map { $0.toDamin() } }
            .map { [weak self] datas in
                guard let self = self else {return Coordinate(latitude: 0, longitude: 0)}
                let data = datas[self.watchOtherLocationIndex]
                self.watchOtherLocationIndex = (self.watchOtherLocationIndex + 1) % datas.count
                return data.currentLocation ?? Coordinate(latitude: 0, longitude: 0)
            }
    }
    
    func unReadChatting(roomID: String) -> Observable<Int> {
        return gameRoomRepository.observingReads(id: roomID)
            .map { [weak self] reads in
                guard let self = self else {return 0}
                return self.checkDidIReadThatChat(chats: reads)
            }
    }
    
    func leave(roomID: String) {
        locationRepository.stopObservingLocation()
        gameRoomRepository.leaveRoom(id: roomID)
    }
    
    func stopOberservingRoom(id: String) {
        gameRoomRepository.removeObserverRoom(id: id)
    }
    
    private func checkDidIReadThatChat(chats: [[String]]) -> Int {
        guard let uuid = userRepository.getUUID() else {return 0}
        var count = 0
        chats.forEach { chat in
            if !chat.contains(uuid) {
                count += 1
            }
        }
        return count
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
