//
//  RoomDTO.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation

struct RoomDTO: Codable {
    let id: String
    let createdAt: Date
    var user: [UserDTO]
    let mapID: [Int]?
    var inGameUserDatas: [InGameUserDataDTO]?
    var gameInformation: [MultiGamePlayerDTO]?
    
    func toRoomUsers() -> [RoomUser] {
        return user.map { $0.toRoomUser() }
    }
    
    mutating func leaveFromRoom(userID: String) {
        self.user = user.filter { $0.id != userID }
    }
    
    mutating func enterRoom(user: UserDTO) {
        self.user.append(user)
    }
    
    init(id: String, user: [UserDTO]) {
        self.id = id
        self.user = user
        self.createdAt = Date()
        self.mapID = nil
        self.inGameUserDatas = nil
        self.gameInformation = nil
    }
}
