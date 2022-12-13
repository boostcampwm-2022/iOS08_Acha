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
            createdAt: createdAt,
            comments: comments
        )
    }
    
    init(data: Post, image: String? = nil) {
        self.id = data.id
        self.userId = data.userId
        self.nickName = data.nickName
        self.text = data.text
        self.image = image
        self.createdAt = data.createdAt
        self.comments = data.comments?.compactMap { CommentDTO(data: $0) }
    }
}
