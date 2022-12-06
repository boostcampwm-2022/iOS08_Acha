//
//  PlayerAnnotation.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import MapKit

final class PlayerAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    let nickName: String
    var point: Int
    
    init(player: MultiGamePlayerData) {
        self.coordinate = player.currentLocation == nil ? CLLocationCoordinate2D(
            latitude: 0,
            longitude: 0
        )  : player.currentLocation!.toCLLocationCoordinate2D()
        self.nickName = player.nickName
        self.point = player.point
        super.init()
    }
    
}
