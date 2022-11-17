//
//  Double+.swift
//  Acha
//
//  Created by 조승기 on 2022/11/16.
//

import Foundation

extension Double {
    func degreeToRadian() -> Double {
        self * .pi / 180
     }
    
    func radianToDegree() -> Double {
        self * 180.0 / .pi
    }
    
    var meterToKmString: String {
        String(format: "%.2f", self/1000) + "km"
    }
}
