//
//  Coordinate.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/21.
//

import Foundation
import MapKit

// MARK: - Coordinate
struct Coordinate: Decodable {
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
    
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
