//
//  Comment.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import Foundation

struct Comment: Hashable {
    var id: Int
    var postId: Int
    let userId: String
    let nickName: String
    let text: String
    let createdAt: Date
    
    init(
        id: Int = -1,
        postId: Int = -1,
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
