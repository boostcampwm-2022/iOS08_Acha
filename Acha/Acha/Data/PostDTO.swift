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
    let nickName: String
    let text: String
    let image: String?
    let createdAt: Date
    let comments: [CommentDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case nickName
        case text
        case image
        case createdAt = "created_at"
        case comments
    }
    
    func toDomain() -> Post {
        let comments = self.comments.map { $0.toDomain() }
        
        return Post(
            id: id,
            userID: userID,
            nickName: nickName,
            text: text,
            image: image,
            createdAt: Date(),
            comments: comments
        )
    }
}
