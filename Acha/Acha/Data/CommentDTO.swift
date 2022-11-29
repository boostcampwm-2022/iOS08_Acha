//
//  CommentDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct CommentDTO: Codable {
    let id: Int
    let userID: String
    let postID: Int
    let text: String
    let createdAt: Date
}
