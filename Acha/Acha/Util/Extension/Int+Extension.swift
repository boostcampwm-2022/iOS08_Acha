//
//  Int+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/16.
//

import Foundation

extension Int {
    func convertToDayHourMinueFormat() -> String {
        var time = self
        let day = String(format: "%02d", time/3600)
        time %= 3600
        let hour = String(format: "%02d", time/60)
        time %= 60
        let minute = String(format: "%02d", time)
        return "\(day):\(hour):\(minute)"
    }
    
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
