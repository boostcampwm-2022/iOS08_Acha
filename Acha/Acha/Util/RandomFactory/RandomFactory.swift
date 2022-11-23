//
//  RandomFactory.swift
//  Acha
//
//  Created by hong on 2022/11/23.
//

import Foundation

struct RandomFactory {
    static func make() -> String {
        let numbers = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "f", "g", "h", "i", "k", "l"]
        var random = ""
        for _ in 0..<16 {
            random += numbers.randomElement()!
        }
        return random
    }
}
