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
        case roomFullError
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
                if roomUsers.count > 3 {
                    return Single<[RoomUser]>.error(RoomError.roomFullError)
                } else {
                    var roomUsers: [RoomUser] = []
                    firebaseRealTimeDatabase.fetch(type: .room(id: id))
                        .map { (roomDTO: RoomDTO) in
                            var roomDTO = roomDTO
                            userRepository.getUserData()
                                .map { roomDTO.enterRoom(user: $0) }
                                .subscribe()
                                .disposed(by: disposeBag)
                            roomUsers = roomDTO.toRoomUsers()
                            firebaseRealTimeDatabase.upload(type: .room(id: id), data: roomDTO)
                            return
                        }
                        .subscribe()
                        .disposed(by: disposeBag)
                    return Single<[RoomUser]>.just(roomUsers)
                }
            }
    }
    
    func makeRoom(id: String) {
        userRepository.getUserData()
            .map {
                let roomDTO = RoomDTO(id: id, user: [$0])
                firebaseRealTimeDatabase.upload(type: .room(id: id), data: roomDTO)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func leaveRoom(id: String) {
        guard let uuid = keychainService.get() else {return}
        firebaseRealTimeDatabase.fetch(type: .room(id: id))
            .map { (roomDTO: RoomDTO) in
                var roomDTO = roomDTO
                roomDTO.user = roomDTO.user.filter { $0.id != uuid }
                if roomDTO.user.count == 0 {
                    deleteRoom(id: id)
                } else {
                    firebaseRealTimeDatabase.upload(type: .room(id: id), data: roomDTO)
                }
                return roomDTO
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func deleteRoom(id: String) {
        firebaseRealTimeDatabase.delete(type: .room(id: id))
    }
    
}
