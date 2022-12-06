//
//  DefaultMultiGameUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation

struct DefaultMultiGameUseCase: MultiGameUseCase {
    
    private let gameRoomRepository: GameRoomRepository
    private let userRepository: UserRepository
    private let recordRepository: RecordRepository
    
    init(
        gameRoomRepository: GameRoomRepository,
        userRepository: UserRepository,
        recordRepository: RecordRepository
    ) {
        self.gameRoomRepository = gameRoomRepository
        self.userRepository = userRepository
        self.recordRepository = recordRepository
    }
}
