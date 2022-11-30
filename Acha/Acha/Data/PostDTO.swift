//
//  PostDTO.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import Foundation

struct PostDTO: Codable {
    let id: Int
    let userID: String
    let text: String
    let image: String?
    let createdAt: String
    let comments: [CommentDTO]?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case text
        case image
        case createdAt = "created_at"
        case comments
    }
}
