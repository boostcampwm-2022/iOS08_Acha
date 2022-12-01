//
//  PostDTO.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import Foundation

struct PostDTO: Codable {
    let id: Int
    let userId: String
    let nickName: String
    let text: String
    let image: String?
    let createdAt: Date
    let comments: [CommentDTO]?
    
    func toDomain() -> Post {
        let comments = comments == nil ? [] : comments?.map { $0.toDomain() }
        
        return Post(
            id: id,
            userId: userId,
            nickName: nickName,
            text: text,
            image: image,
            createdAt: createdAt,
            comments: comments
        )
    }
    
    init(
        id: Int,
        userId: String,
        nickName: String,
        text: String,
        image: String?,
        createdAt: Date = Date(),
        comments: [CommentDTO]? = []
    ) {
        self.id = id
        self.userId = userId
        self.nickName = nickName
        self.text = text
        self.image = image
        self.createdAt = createdAt
        self.comments = comments
    }
}
