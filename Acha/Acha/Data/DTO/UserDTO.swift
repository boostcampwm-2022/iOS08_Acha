//
//  UserDTO.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

struct UserDTO: Codable {
    let id: String
    let password: String
    let nickname: String
    let badges: [BadgeDTO]?
    let records: [RecordDTO]?
    let pinCharacter: String?
    let friends: [UserDTO]?

    func toRoomUser() -> RoomUser {
        return RoomUser(id: id, nickName: nickname)
    }
}
