//
//  MapAnnotation.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/15.
//

import MapKit

// MapAnnotation은 NSObject를 상속해야함
class MapAnnotation: NSObject, MKAnnotation {
    
    let map: Map
    let coordinate: CLLocationCoordinate2D
    let polyLine: MKPolyline
    
    init(map: Map, polyLine: MKPolyline) {
        self.map = map
        self.coordinate = CLLocationCoordinate2D(latitude: map.centerCoordinate.latitude,
                                                 longitude: map.centerCoordinate.longitude)
        self.polyLine = polyLine
        super.init()
    }
}
