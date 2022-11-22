//
//  AchaRecord.swift
//  Acha
//
//  Created by 배남석 on 2022/11/17.
//

import Foundation
 
struct Record: Hashable, Codable {
    var id: Int
    var mapID: Int
    var userID: String
    var calorie: Int
    var distance: Int
    var time: Int
    var isSingleMode: Bool
    var isWin: Bool?
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case mapID = "map_id"
        case userID = "user_id"
        case calorie
        case distance
        case time
        case isSingleMode
        case isWin
        case createdAt = "created_at"
    }
}
