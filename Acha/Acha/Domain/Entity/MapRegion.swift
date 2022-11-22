//
//  MapRegion.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/21.
//

import Foundation

struct MapRegion {
    let center: Coordinate
    let span: CoordinateSpan
}

struct CoordinateSpan {
    let latitudeDelta: Double
    let longitudeDelta: Double
}
