//
//  MultiGameRoomUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation

struct MultiGameRoomUseCase {

    private let repository: MultiGameRoomProvider
    init(repository: MultiGameRoomProvider) {
        self.repository = repository
    }
}
