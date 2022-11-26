//
//  MultiGameRoomDataSource.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation
import RxSwift

protocol MultiGameRoomDataSourceProtocol {
    // 방 만들기
    func make(roomID: String)
    func get(roomID: String) -> Observable<RoomDTO>
    // 방 데이터 얻기
//    func get(roomID: String) -> Observable<RoomDTO>
    // 방 폭파
//    func delete(roomID: String)
    // 방 정보 변경
//    func edit(_ type: FBRealTimeDBType) -> Observable<RoomDTO>
}

struct MultiGameRoomDataSource: MultiGameRoomDataSourceProtocol {
    
    private let provider: FBRealTimeDB
    
    init(provider: FBRealTimeDB) {
        self.provider = provider
    }
    
    func make(roomID: String) {
        provider.make(.room(id: roomID, data: nil))
    }
    
    func get(roomID: String) -> Observable<RoomDTO> {
        return provider.get(.room(id: roomID, data: nil), responseType: RoomDTO.self)
    }
}
