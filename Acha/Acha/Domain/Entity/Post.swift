//
//  Post.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct Post: Hashable {
    let id: Int
    let userId: String
    let nickName: String
    let text: String
    let image: String?
    let createdAt: Date
    var comments: [Comment]?
    
    init(
        id: Int,
        userId: String,
        nickName: String,
        text: String,
        image: String?,
        createdAt: Date = Date(),
        comments: [Comment]?
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
