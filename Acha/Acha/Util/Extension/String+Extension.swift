//
//  String+Extension.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

extension String {
    func stringCheck(pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: self.count)
            if regex.firstMatch(in: self, range: range) != nil {
                return true
            } else {
                return false
            }
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
