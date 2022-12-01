//
//  CommentDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct CommentDTO: Codable {
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
    
    init(data: Comment) {
        self.commentId = data.id
        self.postId = data.postId
        self.nickName = data.nickName
        self.userId = data.userId
        self.text = data.text
        self.createdAt = data.createdAt
    }
}
