//
//  String+.swift
//  Acha
//
//  Created by 조승기 on 2022/11/21.
//

import Foundation

extension String {
    func convertToDateFormat(format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        if let date = dateFormatter.date(from: self) {
            return date
        }
        return Date()
    }
}
