//
//  MultiGameRoomRepository.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation

protocol MultiGameRoomProviderProtocol {
    // 방 만들기
    func make()
    // 방 데이터 얻기
    func get()
    // 방 폭파
    func delete()
    // 방 정보 변경 
    func edit()
}

struct MultiGameRoomProvider {
    
}

struct MultiGameRoomRepository {
    private let provider: MultiGameRoomProvider
    init(provider: MultiGameRoomProvider) {
        self.provider = provider
    }
}
