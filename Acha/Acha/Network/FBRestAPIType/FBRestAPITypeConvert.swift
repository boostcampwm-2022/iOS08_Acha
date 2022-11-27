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
    
    private enum Codingkeys: String, CodingKey {
        case value = "stringValue"
    }
}

struct IntValue: Codable {
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    private enum Codingkeys: String, CodingKey {
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
