//
//  Comment.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import Foundation

struct Comment: Hashable {
    let id: Int
    let postId: Int
    let userId: String
    let nickName: String
    let text: String
    let createdAt: Date
    
    init(
        id: Int,
        postId: Int,
        userId: String,
        nickName: String,
        text: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.nickName = nickName
        self.text = text
        self.createdAt = createdAt
    }
}
