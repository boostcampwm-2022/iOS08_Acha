//
//  Map.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/14.
//

import Foundation

// MARK: - Map
struct Map: Hashable {
    let mapID: Int
    let name: String
    let centerCoordinate: Coordinate
    let coordinates: [Coordinate]
    let location: String
    let image: Data
}
