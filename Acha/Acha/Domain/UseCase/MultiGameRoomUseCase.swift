//
//  MultiGameRoomUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol MultiGameRoomUseCaseProtocol {
    func observing(roomID: String) -> Observable<[RoomUser]>
    func get(roomID: String) -> Single<[RoomUser]>
    func leave(roomID: String)
}

struct MultiGameRoomUseCase: MultiGameRoomUseCaseProtocol {

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
}
