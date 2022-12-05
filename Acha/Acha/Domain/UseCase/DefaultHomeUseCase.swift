//
//  HomeUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

protocol HomeUseCase {
    func getUUID() -> Observable<String>
    func makeRoom() -> Observable<String>
    func enterRoom(id: String) -> Single<[RoomUser]>
}

struct DefaultHomeUseCase: HomeUseCase {
    
    enum HomUseCaseError: Error {
        case uuidNotFound
    }
    
    private let gameRoomRepository: GameRoomRepository
    private let userRepository: UserRepository
    init(
        gameRoomRepository: GameRoomRepository,
        userRepository: UserRepository
    ) {
        self.gameRoomRepository = gameRoomRepository
        self.userRepository = userRepository
    }
    
    func getUUID() -> Observable<String> {
        return Observable<String>.create { observer in
            guard let uuid = userRepository.getUUID() else {
                observer.onError(DefaultHomeUseCase.HomUseCaseError.uuidNotFound)
                return Disposables.create()
            }
            observer.onNext(uuid)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func makeRoom() -> Observable<String> {
        return gameRoomRepository.makeRoom()
    }
    
    func enterRoom(id: String) -> Single<[RoomUser]> {
        return gameRoomRepository.enterRoom(id: id)
    }
    
}
