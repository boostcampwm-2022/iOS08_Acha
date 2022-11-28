//
//  FBRestAPITypeConvert.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation

struct StringValue: Codable {
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    private enum CodingKeys: String, CodingKey {
        case value = "stringValue"
    }
}

struct IntValue: Codable {
    let value: Int
    
    private enum CodingKeys: String, CodingKey {
        case value = "integerValue"
    }
}

struct DoubleValue: Codable {
    let value: Double
    
    private enum CodingKeys: String, CodingKey {
        case value = "doubleValue"
    }
}

struct BoolValue: Codable {
    let value: Bool
    
    private enum CodingKeys: String, CodingKey {
        case value = "booleanValue"
    }
}

struct ArrayValue<T: Codable>: Codable {
    let arrayValue: [String: [T]]

    private enum CodingKeys: String, CodingKey {
        case arrayValue
    }

    init(values: [T]) {
        self.arrayValue = ["values": values]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.arrayValue = try container.decode([String: [T]].self, forKey: .arrayValue)
    }
}

