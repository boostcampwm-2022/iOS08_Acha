//
//  RecordDTO.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

struct RecordDTO: Codable {
    let recordId: Int
    let mapId: Int
    let userID: String
    let calorie: Int
    let distance: Int
    let time: Int
    let isSingleMode: Bool
    let isWin: Bool
    let isCompleted: Bool
    let createdAt: Date
}
