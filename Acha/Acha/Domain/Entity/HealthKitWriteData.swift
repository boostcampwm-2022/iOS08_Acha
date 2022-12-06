//
//  HealthKitWriteData.swift
//  Acha
//
//  Created by hong on 2022/12/01.
//

import Foundation

struct HealthKitWriteData {
    let distance: Int
    let diatanceTime: Int64
    
    let calorie: Int
    let calorieTime: Int64
    
    init(distance: Double, diatanceTime: Int, calorie: Int, calorieTime: Int) {
        self.distance = Int(distance)
        self.diatanceTime = Int64(diatanceTime)
        self.calorie = calorie
        self.calorieTime = Int64(calorieTime)
    }
}
