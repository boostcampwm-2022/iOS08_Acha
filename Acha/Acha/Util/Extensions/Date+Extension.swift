//
//  Date+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/16.
//

import Foundation

extension Date {
    func toYearMonthDateStringFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEE요일"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        return dateFormatter.string(from: self)
    }
}
