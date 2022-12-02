//
//  Date+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/16.
//

import Foundation

extension Date {
    func convertToStringFormat(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ko_kr")
        return dateFormatter.string(from: self)
    }
    
    var secondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970).rounded())
    }
    
    init(seconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    func since(_ from: Int64) -> Date {
        return Date(seconds: self.secondsSince1970 - from)
    }
}
