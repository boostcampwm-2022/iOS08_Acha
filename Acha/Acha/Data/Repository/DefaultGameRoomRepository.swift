//
//  DefaultGameRoomRepository.swift
//  Acha
//
//  Created by hong on 2022/12/04.
//

import Foundation
import RxSwift

struct DefaultGameRoomRepository {
    
    enum RoomError: Error {
        case RoomFullError
    }
    
    private let firebaseRealTimeDatabase: RealtimeDatabaseNetworkService
    private let keychainService: KeychainService
    private let userRepository: UserRepository
    
    private let disposeBag = DisposeBag()
    init(
        fireBaesRealTimeDatabase: RealtimeDatabaseNetworkService,
        keychainService: KeychainService,
        userRepository: UserRepository
    ) {
        self.firebaseRealTimeDatabase = fireBaesRealTimeDatabase
        self.keychainService = keychainService
        self.userRepository = userRepository
        
    }
    
    func fetchRoomData(id: String) -> Single<RoomDTO> {
        return firebaseRealTimeDatabase.fetch(type: .room(id: id))
            .map { (roomDTO: RoomDTO) in
                return roomDTO
            }
    }
    
    func fetchRoomUserData(id: String) -> Single<[RoomUser]> {
        return firebaseRealTimeDatabase.fetch(type: .room(id: id))
            .map { (roomDTO: RoomDTO) in
                return roomDTO.toRoomUsers()
            }
    }
    
    func enterRoom(id: String) -> Single<[RoomUser]> {
        return fetchRoomUserData(id: id)
            .flatMap { roomUsers in
                if roomUsers.count > 4 {
                    return Single<[RoomUser]>.error(RoomError.RoomFullError)
                } else {
                    var roomUsers: [RoomUser] = []
                    firebaseRealTimeDatabase.fetch(type: .room(id: id))
                        .map { (roomDTO: RoomDTO) in
                            var roomDTO = roomDTO
                            userRepository.getUserData()
                                .map { roomDTO.user.append($0) }
                                .subscribe()
                                .disposed(by: disposeBag)
                            roomUsers = roomDTO.toRoomUsers()
                        }
                        .subscribe()
                        .disposed(by: disposeBag)
                    return Single<[RoomUser]>.just(roomUsers)
                }
            }
    }
    
    func leaveRoom(id: String) {
        guard let uuid = keychainService.get() else {return}
        firebaseRealTimeDatabase.fetch(type: .room(id: id))
            .map { (roomDTO: RoomDTO) in
                var roomDTO = roomDTO
                roomDTO.user = roomDTO.user.filter { $0.id != uuid }
                return roomDTO
            }
            .subscribe { roomDTO in
                firebaseRealTimeDatabase.upload(type: .room(id: id), data: roomDTO)
            }
            .disposed(by: disposeBag)
    }
    
    func deleteRoom(id: String) {
        
    }
    
}
