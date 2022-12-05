//
//  BadgeDTO.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

struct BadgeDTO: Codable {
    let id: Int
    let name: String
    let imageURL: String
    let isHidden: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "image"
        case isHidden
    }
    
    func toDomain() -> Badge {
        Badge(id: id,
              name: name,
              imageURL: imageURL,
              isHidden: isHidden)
    }
}
