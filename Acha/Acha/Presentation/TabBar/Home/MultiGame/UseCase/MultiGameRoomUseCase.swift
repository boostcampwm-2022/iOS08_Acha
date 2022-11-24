//
//  MultiGameRoomUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

struct MultiGameRoomUseCase {

    private let repository: MultiGameRoomRepository
    init(repository: MultiGameRoomRepository) {
        self.repository = repository
    }
    
    func make(roomID: String) {
        repository.make(roomID: roomID)
    }
    
//    func get(roomID: String) -> Observable<RoomDTO> {
//        return repository.get(roomID: roomID)
//    }
}
