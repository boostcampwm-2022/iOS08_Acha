//
//  CommentDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct CommentDTO: Codable {
    let postID: Int
    let commentID: Int
    let nickName: String
    let userID: String
    let text: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case postID
        case commentID
        case nickName
        case userID = "user_id"
        case text
        case createdAt = "created_at"
    }
    
    func toDomain() -> Comment {
        return Comment(
            postID: postID,
            commentID: commentID,
            userID: userID,
            nickName: nickName,
            text: text,
            createdAt: Date()
        )
    }
}
