//
//  RoomDTO.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation

struct RoomDTO: Codable {
    let id: String
    var user: [UserDTO]
    let mapID: Int
    
    func toRoomUsers() -> [RoomUser] {
        return user.map { $0.toRoomUser() }
    }
}
