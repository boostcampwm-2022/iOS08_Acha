//
//  MultiGamePlayerDTO.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation

struct MultiGamePlayerDTO: Codable {
    let id: String
    let nickName: String
    let currentLocation: CoordinateDTO
    let point: Int
    let locationHistory: [CoordinateDTO]
}
