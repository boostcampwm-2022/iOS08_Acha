//
//  BadgeFireStoreDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct BadgeFireStoreDTO: Codable {
    let id: IntValue
    let name: StringValue
    let image: StringValue
    let isHidden: BoolValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case id, name, image, isHidden
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        id = try fieldContaier.decode(IntValue.self, forKey: .id)
        name = try fieldContaier.decode(StringValue.self, forKey: .name)
        image = try fieldContaier.decode(StringValue.self, forKey: .image)
        isHidden = try fieldContaier.decode(BoolValue.self, forKey: .isHidden)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.id, forKey: .id)
        try fieldContainer.encode(self.name, forKey: .name)
        try fieldContainer.encode(self.image, forKey: .image)
        try fieldContainer.encode(self.isHidden, forKey: .isHidden)
    }
    
    init(data: BadgeDTO) {
        self.id = IntValue(value: data.id)
        self.name = StringValue(value: data.name)
        self.image = StringValue(value: data.image)
        self.isHidden = BoolValue(value: data.isHidden)
    }
    
}
