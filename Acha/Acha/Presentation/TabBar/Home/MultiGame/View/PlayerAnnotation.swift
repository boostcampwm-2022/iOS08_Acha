//
//  PlayerAnnotation.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import MapKit

final class PlayerAnnotation: NSObject, MKAnnotation {
    
    enum PlayerType: Int {
        case first = 0
        case second = 1
        case third = 2
        case fourth = 3
    }
    
    var coordinate: CLLocationCoordinate2D
    let nickName: String
    let point: Int
    private let type: PlayerType
    let title: String?
    let subtitle: String?
    
    init(player: MultiGamePlayerData, type: PlayerType) {
        self.coordinate = player.currentLocation == nil ? CLLocationCoordinate2D(
            latitude: 0,
            longitude: 0
        )  : player.currentLocation!.toCLLocationCoordinate2D()
        self.nickName = player.nickName
        self.point = player.point
        self.type = type
        self.title = player.nickName
        self.subtitle = "\(player.point) 점"
        super.init()
    }
    
    func image() -> UIImage? {
        switch type {
        case .first:
            return .firstAnnotation
        case .second:
            return .secondAnnotation
        case .third:
            return .thirdAnnotation
        case .fourth:
            return .fourthAnnotation
        }
    }
    
}
