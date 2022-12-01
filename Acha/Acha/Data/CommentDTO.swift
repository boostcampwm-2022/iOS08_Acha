//
//  CommentDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct CommentDTO: Codable {
    let id: Int
    let postId: Int
    let nickName: String
    let userId: String
    let text: String
    let createdAt: Date
    
    func toDomain() -> Comment {
        return Comment(
            id: id,
            postId: postId,
            userId: userId,
            nickName: nickName,
            text: text,
            createdAt: createdAt
        )
    }
    
    init(
        id: Int,
        postId: Int,
        nickName: String,
        userId: String,
        text: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.nickName = nickName
        self.userId = userId
        self.text = text
        self.createdAt = createdAt
    }
}
