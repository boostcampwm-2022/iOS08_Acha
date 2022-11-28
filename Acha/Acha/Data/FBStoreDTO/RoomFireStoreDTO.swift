//
//  RoomFireStoreDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct RoomFireStoreDTO: Codable {
    let id: StringValue
    let createdAt: IntValue
    var user: [UserFireStoreDTO]
    let mapID: [IntValue]?
    var inGameUserDatas: [InGameUserDataFireStoreDTO]?
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case id, createdAt, user, mapID, inGameUserDatas
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        id = try fieldContaier.decode(StringValue.self, forKey: .id)
        createdAt = try fieldContaier.decode(IntValue.self, forKey: .createdAt)
        user = try fieldContaier.decode([UserFireStoreDTO].self, forKey: .user)
        mapID = try fieldContaier.decode([IntValue].self, forKey: .mapID)
        inGameUserDatas = try fieldContaier.decode([InGameUserDataFireStoreDTO].self, forKey: .inGameUserDatas)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.id, forKey: .id)
        try fieldContainer.encode(self.createdAt, forKey: .createdAt)
        try fieldContainer.encode(self.user, forKey: .user)
        try fieldContainer.encode(self.mapID, forKey: .mapID)
        try fieldContainer.encode(self.inGameUserDatas, forKey: .inGameUserDatas)
    }
}
