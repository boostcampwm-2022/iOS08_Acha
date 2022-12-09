//
//  MultiGamePlayerData.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation

struct MultiGamePlayerData: Hashable {
    let id: String
    let nickName: String
    let currentLocation: Coordinate?
    let point: Int
}
