//
//  RecordDTO.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

struct RecordDTO: Codable {
    let id: Int
    let mapID: Int
    let userID: String
    let calorie: Int
    let distance: Int
    let time: Int
    let isSingleMode: Bool
    let isWin: Bool?
    let isCompleted: Bool
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case mapID = "map_id"
        case userID = "user_id"
        case calorie
        case distance
        case time
        case isSingleMode
        case isWin
        case isCompleted
        case createdAt = "created_at"
    }
    
    func toDomain() -> Record {
        return Record(id: id,
                      mapID: mapID,
                      userID: userID,
                      calorie: calorie,
                      distance: distance,
                      time: time,
                      isSingleMode: isSingleMode,
                      isWin: isWin,
                      isCompleted: isCompleted,
                      createdAt: createdAt)
    }
}
