//
//  RandomFactory.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation

struct RandomFactory {
    static func make() -> String {
        let numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        var random = ""
        for _ in 0..<16 {
            random += numbers.randomElement()!
        }
        return random
    }
}
