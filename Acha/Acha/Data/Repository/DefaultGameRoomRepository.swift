//
//  DefaultGameRoomRepository.swift
//  Acha
//
//  Created by hong on 2022/12/04.
//

import Foundation
import RxSwift

struct DefaultGameRoomRepository: GameRoomRepository {
    
    enum RoomError: Error, LocalizedError {
        case roomFullError
        case noUserData
            
        var errorDescription: String? {
            switch self {
            case .noUserData:
                return "유저 데이터가 없습니다🥲🥲😢"
            case .roomFullError:
                return "방이 꽉 찼습니다😭😭😭"
            }
        }
    }
    
    private let firebaseRealTimeDatabase: RealtimeDatabaseNetworkService
    private let keychainService: KeychainService
    private let randomService: RandomService
    
    private let disposeBag = DisposeBag()
    init(
        fireBaesRealTimeDatabase: RealtimeDatabaseNetworkService,
        keychainService: KeychainService,
        randomService: RandomService
    ) {
        self.firebaseRealTimeDatabase = fireBaesRealTimeDatabase
        self.keychainService = keychainService
        self.randomService = randomService
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
        return fetchRoomData(id: id)
            .flatMap { roomDTO in
                var roomDTO = roomDTO
                if roomDTO.user.count <= 3 {
                    getUserDataFromRealTimeDataBaseService()
                        .subscribe { userDTO in
                            roomDTO.enterRoom(user: userDTO)
                            firebaseRealTimeDatabase.upload(type: .room(id: id), data: roomDTO)
                        }
                        .disposed(by: disposeBag)
                    return fetchRoomUserData(id: id)
                } else {
                    return Single<[RoomUser]>.error(RoomError.roomFullError)
                }
            }
    }
    
    func makeRoom() -> Observable<String> {
        return Observable<String>.create { observer in
            getUserDataFromRealTimeDataBaseService()
                .map {
                    let roomId = randomService.make()
                    let roomDTO = RoomDTO(id: roomId, user: [$0])
                    firebaseRealTimeDatabase.upload(type: .room(id: roomId), data: roomDTO)
                    observer.onNext(roomId)
                }
                .subscribe()
                .disposed(by: disposeBag)
            return Disposables.create()
            }
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
    
    func observingRoom(id: String) -> Observable<RoomDTO> {
        return firebaseRealTimeDatabase.observing(type: .room(id: id))
            .map { (roomDTO: RoomDTO) in
                return roomDTO
            }
    }
    
    func observingMultiGamePlayers(id: String) -> Observable<[MultiGamePlayerData]> {
        return observingRoom(id: id)
            .map { $0.gameInformation ?? [] }
            .map { $0.map { $0.toDamin() } }
    }
    
    func startGame(roomId: String) {
        fetchRoomData(id: roomId)
            .subscribe(onSuccess: { roomDTO in
                var roomDTO = roomDTO
                roomDTO.gameInformation = roomDTO.user.map {
                    MultiGamePlayerDTO(data: makeInitMultiGamePlayerData(data: $0), history: [])
                }
                firebaseRealTimeDatabase.upload(type: .room(id: roomId), data: roomDTO)
            })
            .disposed(by: disposeBag)
    }
    
    private func makeInitMultiGamePlayerData(data: UserDTO) -> MultiGamePlayerData {
        return MultiGamePlayerData(id: data.id,
                                   nickName: data.nickname,
                                   currentLocation: .init(latitude: 0, longitude: 0),
                                   point: 0)
    }
    
    func updateMultiGamePlayer(
        roomId: String,
        data: MultiGamePlayerData,
        histroy: [Coordinate]
    ) {
        let multiGamePlayerDTO = MultiGamePlayerDTO(data: data, history: histroy)
        
        fetchRoomData(id: roomId)
            .subscribe(onSuccess: { roomDTO in
                var roomDTO = roomDTO
                guard let index = roomDTO.gameInformation?.firstIndex(where: {
                    $0.id == multiGamePlayerDTO.id
                }) else {return}
                roomDTO.gameInformation?[index] = multiGamePlayerDTO
                firebaseRealTimeDatabase.upload(type: .room(id: roomId), data: roomDTO)
            })
            .disposed(by: disposeBag)
    }
    
    func observingRoomUser(id: String) -> Observable<[RoomUser]> {
        return observingRoom(id: id).map { $0.toRoomUsers() }
    }
    
    func removeObserverRoom(id: String) {
        return firebaseRealTimeDatabase.removeObserver(type: .room(id: id))
    }
    
    private func getUserDataFromRealTimeDataBaseService() -> Single<UserDTO> {
        guard let uuid = keychainService.get() else {
            return Single<UserDTO>.error(RoomError.noUserData)
        }
        return firebaseRealTimeDatabase.fetch(type: .user(id: uuid))
    }
    
}
