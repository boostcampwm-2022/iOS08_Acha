//
//  RecordFireStoreDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct RecordFireStoreDTO: Codable {
    let recordId: IntValue
    let mapId: IntValue
    let userID: StringValue
    let calorie: IntValue
    let distance: IntValue
    let time: IntValue
    let isSingleMode: BoolValue
    let isWin: BoolValue
    let createdAt: IntValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case recordId, mapId, userID, calorie, distance, time, isSingleMode, isWin, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        recordId = try fieldContaier.decode(IntValue.self, forKey: .recordId)
        mapId = try fieldContaier.decode(IntValue.self, forKey: .mapId)
        userID = try fieldContaier.decode(StringValue.self, forKey: .userID)
        calorie = try fieldContaier.decode(IntValue.self, forKey: .calorie)
        distance = try fieldContaier.decode(IntValue.self, forKey: .distance)
        time = try fieldContaier.decode(IntValue.self, forKey: .time)
        isSingleMode = try fieldContaier.decode(BoolValue.self, forKey: .isSingleMode)
        isWin = try fieldContaier.decode(BoolValue.self, forKey: .isWin)
        createdAt = try fieldContaier.decode(IntValue.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.recordId, forKey: .recordId)
        try fieldContainer.encode(self.mapId, forKey: .mapId)
        try fieldContainer.encode(self.userID, forKey: .userID)
        try fieldContainer.encode(self.calorie, forKey: .calorie)
        try fieldContainer.encode(self.distance, forKey: .distance)
        try fieldContainer.encode(self.time, forKey: .time)
        try fieldContainer.encode(self.isSingleMode, forKey: .isSingleMode)
        try fieldContainer.encode(self.isWin, forKey: .isWin)
        try fieldContainer.encode(self.createdAt, forKey: .createdAt)
    }
}
