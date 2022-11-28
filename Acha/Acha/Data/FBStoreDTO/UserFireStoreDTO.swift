//
//  UserFireStoreDTO.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation

struct UserFireStoreDTO: Codable {
    let id: StringValue
    let nickname: StringValue
    let password: StringValue
    let bages: ArrayValue<IntValue>
    let records: ArrayValue<IntValue>
    let pinCharacter: StringValue
    let friends: ArrayValue<StringValue>
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case id
        case nickname
        case password
        case badges
        case friends
        case records
        case pinCharacter
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        id = try fieldContaier.decode(StringValue.self, forKey: .id)
        nickname = try fieldContaier.decode(StringValue.self, forKey: .nickname)
        password = try fieldContaier.decode(StringValue.self, forKey: .password)
        bages = try fieldContaier.decode(ArrayValue<IntValue>.self, forKey: .badges)
        records = try fieldContaier.decode(ArrayValue<IntValue>.self, forKey: .records)
        pinCharacter = try fieldContaier.decode(StringValue.self, forKey: .pinCharacter)
        friends = try fieldContaier.decode(ArrayValue<StringValue>.self, forKey: .friends)
    }
    
    init(data: UserDTO) {
        self.id = StringValue(value: data.id)
        self.nickname = StringValue(value: data.nickname)
        self.password = StringValue(value: data.password)
        let recordS = data.records ?? []
        self.records = ArrayValue(values: recordS.map { IntValue(value: $0.recordId) })
        self.pinCharacter = StringValue(value: data.pinCharacter ?? "")
        let badgeS = data.badges ?? []
        self.bages = ArrayValue(values: badgeS.map { IntValue(value: $0.id) })
        let friendS = data.friends ?? []
        self.friends = ArrayValue(values: friendS.map { StringValue(value: $0.id) })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.id, forKey: .id)
        try fieldContainer.encode(self.nickname, forKey: .nickname)
        try fieldContainer.encode(self.password, forKey: .password)
        try fieldContainer.encode(self.bages, forKey: .badges)
        try fieldContainer.encode(self.pinCharacter, forKey: .pinCharacter)
        try fieldContainer.encode(self.records, forKey: .records)
        try fieldContainer.encode(self.friends, forKey: .friends)
    }
}
