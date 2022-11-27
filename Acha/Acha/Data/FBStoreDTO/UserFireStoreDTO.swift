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
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case id
        case nickname
        case password
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        id = try fieldContaier.decode(StringValue.self, forKey: .id)
        nickname = try fieldContaier.decode(StringValue.self, forKey: .nickname)
        password = try fieldContaier.decode(StringValue.self, forKey: .password)
    }
    
    init(data: UserDTO) {
        self.id = StringValue(value: data.id)
        self.nickname = StringValue(value: data.nickname)
        self.password = StringValue(value: data.password)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.id, forKey: .id)
        try fieldContainer.encode(self.nickname, forKey: .nickname)
        try fieldContainer.encode(self.password, forKey: .password)
    }
}
