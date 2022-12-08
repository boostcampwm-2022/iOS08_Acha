//
//  Post.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct Post: Hashable {
    var id: Int
    let userId: String
    let nickName: String
    let text: String
    var image: String?
    let createdAt: Date
    var comments: [Comment]?
    
    init() {
        self.id = -1
        self.userId = ""
        self.nickName = ""
        self.text = ""
        self.image = nil
        self.createdAt = Date()
        self.comments = nil
    }
    
    init(
        id: Int = -1,
        userId: String,
        nickName: String,
        text: String,
        image: String? = nil,
        createdAt: Date = Date(),
        comments: [Comment]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.nickName = nickName
        self.text = text
        self.image = image
        self.createdAt = createdAt
        self.comments = comments
    }
    
    mutating func addComment(data: Comment) {
        comments?.append(data)
    }
}
