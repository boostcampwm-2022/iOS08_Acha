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
}
