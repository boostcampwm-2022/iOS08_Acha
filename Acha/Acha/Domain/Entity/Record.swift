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
    
    // FIXME: init 함수를 분리해서 초기값이 없는 상태 데이터 입력을 통한 초기화를 분리하는게 안전해 보입니다.
    init(id: Int = -1,
         mapID: Int = -1,
         userID: String = "",
         calorie: Int = -1,
         distance: Int = -1,
         time: Int = Int.max,
         isSingleMode: Bool = true,
         isWin: Bool? = nil,
         createdAt: String = "") {
        self.id = id
        self.mapID = mapID
        self.userID = userID
        self.calorie = calorie
        self.distance = distance
        self.time = time
        self.isSingleMode = isSingleMode
        self.isWin = isWin
        self.createdAt = createdAt
    }
}
