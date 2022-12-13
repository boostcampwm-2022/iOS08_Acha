//
//  PlayerCircle.swift
//  Acha
//
//  Created by hong on 2022/12/07.
//

import Foundation
import MapKit

final class PlayerCircle: MKCircle {
    
    var type: CircleType = .first
    
    func overlayColor() -> UIColor? {
        switch type {
        case .first:
            return .red
        case .second:
            return .purple
        case .third:
            return .blue
        case .fourth:
            return .black
        }
    }
}
