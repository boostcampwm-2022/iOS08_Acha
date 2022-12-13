//
//  MultiGameUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import RxRelay

protocol MultiGameUseCase {
    
    var inGamePlayersData: BehaviorRelay<[MultiGamePlayerData]> {get set}
    var unReadsCount: BehaviorRelay<Int> {get set}
    var currentRoomPlayerData: BehaviorRelay<[RoomUser]> {get set}
    
    func timerStart() -> Observable<Int>
    func timerStop()
    
    func getLocation() -> Observable<Coordinate>
    func point() -> Observable<Int>
    var visitedLocation: Set<Coordinate> {get set}
    var movedDistance: Double {get set}
    
    func healthKitStore(time: Int)
    func healthKitAuthorization() -> Observable<Void>
    func updateData(roomId: String)
    
    func initVisitedLocation()
    
    func stopObserveLocation()
    
    func observing(roomID: String)
    func watchOthersLocation(roomID: String) -> Single<Coordinate>
    
    func leave(roomID: String)
    
    func unReadChatting(roomID: String) -> Observable<Int>
    func stopOberservingRoom(id: String)
    
    func gameOver(roomID: String) -> Observable<Bool>

}
