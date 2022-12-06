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
    let currentLocation: CoordinateDTO?
    let point: Int
    let locationHistory: [CoordinateDTO]?
    
    func toDamin() -> MultiGamePlayerData {
        return MultiGamePlayerData(
            id: id,
            nickName: nickName,
            currentLocation: currentLocation == nil ? nil : currentLocation?.toDomain(),
            point: point
        )
    }
    
    init(data: MultiGamePlayerData, history: [Coordinate]) {
        self.id = data.id
        self.nickName = data.nickName
        self.currentLocation = data.currentLocation == nil ? nil : CoordinateDTO(data: data.currentLocation!)
        self.point = data.point
        self.locationHistory = history.map { CoordinateDTO(data: $0) }
    }
}
