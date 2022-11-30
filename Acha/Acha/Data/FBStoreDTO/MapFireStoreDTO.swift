//
//  MapFireStoreDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct MapFireStoreDTO: Codable {
    
    let mapID: IntValue
    let name: StringValue
    let centerCoordinate: CoordinateFireSoreDTO
    let coordinates: [CoordinateFireSoreDTO]
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case mapID, name, centerCoordinate, coordinates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        self.mapID = try fieldContaier.decode(IntValue.self, forKey: .mapID)
        self.name = try fieldContaier.decode(StringValue.self, forKey: .name)
        self.centerCoordinate = try fieldContaier.decode(CoordinateFireSoreDTO.self, forKey: .centerCoordinate)
        self.coordinates = try fieldContaier.decode([CoordinateFireSoreDTO].self, forKey: .coordinates)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.mapID, forKey: .mapID)
        try fieldContainer.encode(self.name, forKey: .name)
        try fieldContainer.encode(self.centerCoordinate, forKey: .centerCoordinate)
        try fieldContainer.encode(self.coordinates, forKey: .coordinates)
    }
}
