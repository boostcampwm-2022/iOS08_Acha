//
//  FBRealTimeDB.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation
import FirebaseDatabase
import RxSwift
import RxRelay

protocol FBRealTimeDBProtocol {
    ///  리얼타임 데이터베이스에 데이터를 만들 수 있는 메서드
    func make(_ type: FBRealTimeDBType)
}

struct FBRealTimeDB: FBRealTimeDBProtocol {
    
    let ref = Database.database().reference()
    
    private func getData<T: Decodable>(
        _ type: FBRealTimeDBType,
        responseType: T.Type,
        handler: @escaping ((T) -> Void)
    ) {
        ref.child(type.path).getData { error, snapshot in
            guard error == nil else {
                return
            }
            guard let snapData = snapshot?.value as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: snapData),
                  let list = try? JSONDecoder().decode(T.self, from: data) else {
                return
            }
            handler(list)
        }
    }
    
    func make(_ type: FBRealTimeDBType) {
        switch type {
        case .user(id: _, data: _):
            ref.child(type.path).setValue(type.data)
        case .room(id: _, data: _):
            guard let uuid = try? KeyChainManager.get() else {return}
            getData(.user(id: uuid, data: nil), responseType: UserDTO.self) { userData in
                let newRoomData = RoomDTO(id: type.id, user: [userData])
                ref.child(type.path).setValue(newRoomData.dictionary)
            }
        default:
            break
        }
    }
    
    func enter(
        _ who: FBRealTimeDBType,
        _ to: FBRealTimeDBType
    ) {
        getData(to, responseType: RoomDTO.self) { roomData in
            var roomData = roomData
            getData(who, responseType: UserDTO.self) { userData in
                roomData.enterRoom(user: userData)
                update(.room(id: roomData.id, data: roomData))
            }
        }
    }
    
    func update(_ type: FBRealTimeDBType) {
        ref.child(type.path).setValue(type.data)
    }
    
    func get<T: Decodable>(
        _ type: FBRealTimeDBType,
        responseType: T.Type
    ) -> Observable<T> {
        
        return Observable<T>.create { observer in
            ref.child(type.path).getData { error, snapshot in
                guard error == nil else { return }
                guard let snapData = snapshot?.value as? [String: Any],
                      let data = try? JSONSerialization.data(withJSONObject: snapData),
                      let list = try? JSONDecoder().decode(T.self, from: data) else { return }
                observer.onNext(list)
            }
            return Disposables.create()
        }
    }
    
    func delete(_ type: FBRealTimeDBType) {
        ref.child(type.path).removeValue()
    }
    
    func leave(from: FBRealTimeDBType) {
        getData(from, responseType: RoomDTO.self) { roomDTO in
            guard let uuid = try? KeyChainManager.get() else {return}
            var roomData = roomDTO
            roomData.leaveFromRoom(userID: uuid)
            if roomData.user.count == 0 {
                delete(from)
                return
            }
            update(.room(id: roomData.id, data: roomData))
        }
    }
}
