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
        let day = time / 3600
        time %= 3600
        let hour = time/60
        time %= 60
        let minute = time
        return "\(day):\(hour):\(minute)"
    }
}
