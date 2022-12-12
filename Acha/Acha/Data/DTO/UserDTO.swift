//
//  UserDTO.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

struct UserDTO: Codable {
    let id: String
    let nickname: String
    let badges: [Int]?
    let records: [Int]?
    let pinCharacter: String?
    let friends: [Int]?

    func toRoomUser() -> RoomUser {
        return RoomUser(id: id, nickName: nickname)
    }
    
    func toDomain() -> User {
        return User(id: id,
                    nickName: nickname,
                    badges: badges ?? [],
                    records: records ?? [],
                    pinCharacter: pinCharacter ?? "",
                    friends: friends ?? [])
    }
}
