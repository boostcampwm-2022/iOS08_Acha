//
//  CommentDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct CommentDTO: Codable {
//    let id: Int
    let commentId: Int
    let postId: Int
    let nickName: String
    let userId: String
    let text: String
    let createdAt: Date
    
    func toDomain() -> Comment {
        return Comment(
            id: commentId,
            postId: postId,
            userId: userId,
            nickName: nickName,
            text: text,
            createdAt: createdAt
        )
    }
    
    init(
        commentId: Int,
        postId: Int,
        nickName: String,
        userId: String,
        text: String,
        createdAt: Date = Date()
    ) {
        self.commentId = commentId
        self.postId = postId
        self.nickName = nickName
        self.userId = userId
        self.text = text
        self.createdAt = createdAt
    }
}
