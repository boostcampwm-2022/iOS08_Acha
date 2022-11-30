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
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case postID = "post_id"
        case text
        case createdAt = "created_at"
    }
}
