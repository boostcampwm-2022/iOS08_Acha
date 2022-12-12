//
//  FirebaseStorageType.swift
//  Acha
//
//  Created by 배남석 on 2022/12/07.
//

import Foundation

enum FirebaseStorageType {
    case map
    case category(String)
    case badge
    case pinCharacter
    
    var path: String {
        switch self {
        case .map:
            return "Map"
        case .category(let name):
            return "Category/\(name)"
        case .badge:
            return "Badge"
        case .pinCharacter:
            return "PinCharacter"
        }
    }
}
