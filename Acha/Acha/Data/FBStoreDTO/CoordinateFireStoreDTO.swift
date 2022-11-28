//
//  CoordinateFireStoreDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct CoordinateFireSoreDTO: Codable {
    let latitude, longitude: DoubleValue
    
    private enum RootKey: String, CodingKey {
        case fields
    }
    
    private enum FieldKeys: String, CodingKey {
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKey.self)
        let fieldContaier = try container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        self.latitude = try fieldContaier.decode(DoubleValue.self, forKey: .latitude)
        self.longitude = try fieldContaier.decode(DoubleValue.self, forKey: .longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootKey.self)
        var fieldContainer = container.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldContainer.encode(self.latitude, forKey: .latitude)
        try fieldContainer.encode(self.longitude, forKey: .longitude)
    }
    
}
