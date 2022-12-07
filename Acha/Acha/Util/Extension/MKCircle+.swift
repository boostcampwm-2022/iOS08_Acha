//
//  MKCircle+.swift
//  Acha
//
//  Created by hong on 2022/12/07.
//

import UIKit
import MapKit

extension MKCircle {
    enum CircleType: Int {
        case first = 0
        case second = 1
        case third = 2
        case fourth = 3 
    }
    
    private static var savedCircleType: CircleType = .first
    
    var type: CircleType {
        get {
            return MKCircle.savedCircleType
        }
        set(newValue) {
            MKCircle.savedCircleType = newValue
        }
    }
    
    var overLayColor: UIColor {
        switch type {
        case .first:
            return .red
        case .second:
            return .orange
        case .third:
            return .yellow
        case .fourth:
            return .green
        }
    }
}
