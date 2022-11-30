//
//  CoordinateDTO.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation

struct CoordinateDTO: Codable {
    let latitude, longitude: Double
    
    func distance(from: Coordinate) -> Double {
        let theta = self.longitude - from.longitude
        let dist = sin(self.latitude.degreeToRadian()) *
        sin(from.latitude.degreeToRadian()) +
        cos(self.latitude.degreeToRadian()) *
        cos(from.latitude.degreeToRadian()) *
        cos(theta.degreeToRadian())
    
        return acos(dist).radianToDegree() * 60 * 1.853159616 * 1000
    }
}
