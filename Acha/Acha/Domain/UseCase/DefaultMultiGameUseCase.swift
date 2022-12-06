//
//  DefaultMultiGameUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import RxCocoa

struct DefaultMultiGameUseCase: MultiGameUseCase {
    
    private let gameRoomRepository: GameRoomRepository
    private let userRepository: UserRepository
    private let recordRepository: RecordRepository
    private let timeRepository: TimeRepository
    private let locationRepository: LocationRepository
    
    init(
        gameRoomRepository: GameRoomRepository,
        userRepository: UserRepository,
        recordRepository: RecordRepository,
        timeRepository: TimeRepository,
        locationRepository: LocationRepository
    ) {
        self.gameRoomRepository = gameRoomRepository
        self.userRepository = userRepository
        self.recordRepository = recordRepository
        self.timeRepository = timeRepository
        self.locationRepository = locationRepository
    }
    
    func timerStart() -> Observable<Int> {
        return timeRepository.setTimer(time: 60)
    }
    
    func timerStop() {
        timeRepository.stopTimer()
    }
}
