//
//  Double+.swift
//  Acha
//
//  Created by 조승기 on 2022/11/16.
//

import Foundation

extension Double {
    func deg2rad() -> Double {
        self * .pi / 180
     }
    
    func rad2deg() -> Double {
        self * 180.0 / .pi
    }
    
    var meter2KmString: String {
        String(format: "%.2f", self/1000) + "km"
    }
}
