//
//  MultiGameRoomUseCase.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation
import RxSwift

struct DefaultMultiGameRoomUseCase: MultiGameRoomUseCase {
    
    enum GameRoomError: Error, LocalizedError {
        case notAvailiableUserNumber
        
        var errorDescription: String? {
            switch self {
            case .notAvailiableUserNumber:
                return "2명 이상이여야 게임을 시작할 수 있습니다 ✌️✌️✌️"
            }
        }
    }
    private let disposebag = DisposeBag()

    private let repository: GameRoomRepository
    init(repository: GameRoomRepository) {
        self.repository = repository
    }
    
    func observing(roomID: String) -> Observable<[RoomUser]> {
        return repository.observingRoom(id: roomID).map { $0.toRoomUsers() }
    }
    
    func get(roomID: String) -> Single<[RoomUser]> {
        return repository.fetchRoomUserData(id: roomID)
    }
    
    func leave(roomID: String) {
        repository.leaveRoom(id: roomID)
    }
    
    func removeObserver(roomID: String) {
        repository.removeObserverRoom(id: roomID)
    }
    
    func isGameAvailable(roomID: String) -> Observable<Void> {
        return Observable<Void>.create { observer in
            get(roomID: roomID)
                .map { roomUsers in
                    if 2...4 ~= roomUsers.count {
                        observer.onNext(())
                    } else {
                        observer.onError(GameRoomError.notAvailiableUserNumber)
                    }
                }
                .subscribe()
                .disposed(by: disposebag)
            return Disposables.create()
        }
    }
}
