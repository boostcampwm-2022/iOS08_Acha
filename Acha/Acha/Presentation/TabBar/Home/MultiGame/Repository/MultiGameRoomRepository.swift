//
//  MultiGameRoomRepository.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift
import FirebaseDatabase
import FirebaseAuth

struct MultiGameRoomRepository {
    private let dataSource: MultiGameRoomDataSource
    init(dataSource: MultiGameRoomDataSource) {
        self.dataSource = dataSource
    }
    func make(roomID: String) {
        dataSource.make(roomID: roomID)
    }
    
    func detect(roomID: String) -> Observable<RoomDTO> {
        return dataSource.detect(roomID: roomID)
    }
}
