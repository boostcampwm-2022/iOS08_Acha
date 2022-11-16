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
}
