//
//  MultiGameRoomDataSource.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation
import RxSwift

protocol MultiGameRoomDataSourceProtocol {

    func make(roomID: String)
    func get(roomID: String) -> Observable<RoomDTO>
    func leave(roomID: String)
}

struct MultiGameRoomDataSource: MultiGameRoomDataSourceProtocol {
    
    private let provider: FBRealTimeDB
    
    init(provider: FBRealTimeDB) {
        self.provider = provider
    }
    
    func make(roomID: String) {
        provider.make(FBRealTimeDBType.room(id: roomID, data: nil))
    }
    
    func get(roomID: String) -> Observable<RoomDTO> {
        return provider.get(
            FBRealTimeDBType.room(id: roomID, data: nil),
            responseType: RoomDTO.self
        )
    }
    
    func leave(roomID: String) {
        provider.leaveRoom(from: FBRealTimeDBType.room(id: roomID, data: nil))
    }
}
