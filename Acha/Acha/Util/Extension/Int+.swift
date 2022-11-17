//
//  Int+.swift
//  Acha
//
//  Created by 배남석 on 2022/11/17.
//

import Foundation

extension Int {
    var convertToDecimal: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
    var converToTime: String {
        var time = self
        
        let hour = time / 3600
        time %= 3600
        let minute = time / 60
        time %= 60
        
        return String(format: "%02d:%02d:%02d", hour, minute, time)
    }
}
