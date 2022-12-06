//
//  MultiGameRoomUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

struct DefaultMultiGameRoomUseCase: MultiGameRoomUseCase {

    private let repository: GameRoomRepository
    init(repository: GameRoomRepository) {
        self.repository = repository
    }
    
    func observing(roomID: String) -> Observable<[RoomUser]> {
        return repository.observingRoom(id: roomID).map { $0.toRoomUsers() }
    }
    
    func get(roomID: String) -> Single<[RoomUser]> {
        return repository.fetchRoomUserData(id: roomID)
    }
    
    func leave(roomID: String) {
        repository.leaveRoom(id: roomID)
    }
    
    func removeObserver(roomID: String) {
        repository.removeObserverRoom(id: roomID)
    }
}
