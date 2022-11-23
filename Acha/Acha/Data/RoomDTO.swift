//
//  RoomDTO.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation

struct RoomDTO: Codable {
    let id: String
    let user: [UserDTO]?
    let mapID: Int
}
