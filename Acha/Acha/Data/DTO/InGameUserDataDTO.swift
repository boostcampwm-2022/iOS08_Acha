//
//  InGameUserData.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation

struct InGameUserDataDTO: Codable, Comparable {
    static func < (lhs: InGameUserDataDTO, rhs: InGameUserDataDTO) -> Bool {
        return lhs.eatenMapID.count < rhs.eatenMapID.count
    }
    
    static func == (lhs: InGameUserDataDTO, rhs: InGameUserDataDTO) -> Bool {
        return lhs.eatenMapID.count == rhs.eatenMapID.count
    }
    
    let userID: String
    let eatenMapID: [Int]
    var routes: [CoordinateDTO]
}
