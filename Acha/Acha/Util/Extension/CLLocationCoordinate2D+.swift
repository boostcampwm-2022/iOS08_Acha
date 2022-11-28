//
//  CLLocationCoordinate2D+.swift
//  Acha
//
//  Created by 조승기 on 2022/11/15.
//

import MapKit

// swiftlint:disable identifier_name
extension CLLocationCoordinate2D {
    func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return to.distance(from: from)
    }

    static func from(coordiate: Coordinate) -> CLLocationCoordinate2D {
        CLLocationCoordinate2DMake(coordiate.latitude, coordiate.longitude)
    }
}
