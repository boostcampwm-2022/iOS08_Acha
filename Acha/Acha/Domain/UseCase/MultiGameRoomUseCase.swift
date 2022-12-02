//
//  MultiGameRoomUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol MultiGameRoomUseCaseProtocol {
    func make(roomID: String)
    func get(roomID: String) -> Observable<[RoomUser]>
    func leave(roomID: String)
}

struct MultiGameRoomUseCase: MultiGameRoomUseCaseProtocol {

    private let repository: MultiGameRoomRepositoryProtocol
    init(repository: MultiGameRoomRepositoryProtocol) {
        self.repository = repository
    }
    
    func make(roomID: String) {
        repository.make(roomID: roomID)
    }
    
    func get(roomID: String) -> Observable<[RoomUser]> {
        return repository.get(roomID: roomID)
    }
    
    func leave(roomID: String) {
        repository.leave(roomID: roomID)
    }
}
