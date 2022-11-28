//
//  InGameUserDataFireStoreDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct InGameUserDataFireStoreDTO: Codable {
    let userID: StringValue
    let eatenMapID: [IntValue]
    var routes: [CoordinateFireSoreDTO]

    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case userID, eatenMapID, routes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        userID = try fieldContaier.decode(StringValue.self, forKey: .userID)
        eatenMapID = try fieldContaier.decode([IntValue].self, forKey: .eatenMapID)
        routes = try fieldContaier.decode([CoordinateFireSoreDTO].self, forKey: .routes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.userID, forKey: .userID)
        try fieldContainer.encode(self.eatenMapID, forKey: .eatenMapID)
        try fieldContainer.encode(self.routes, forKey: .routes)
    }
}
