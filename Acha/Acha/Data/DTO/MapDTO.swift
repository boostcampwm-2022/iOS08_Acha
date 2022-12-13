//
//  MapDTO.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation

struct MapDTO: Codable {
    let mapID: Int
    let name: String
    let centerCoordinate: CoordinateDTO
    let coordinates: [CoordinateDTO]
    let location: String
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case mapID = "mapId"
        case name, centerCoordinate, coordinates, location, image
    }
}
