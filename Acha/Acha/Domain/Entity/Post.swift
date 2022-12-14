//
//  Post.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct Post: Hashable {
    var id: Int
    var userId: String
    var nickName: String
    var text: String
    var image: Data?
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
        image: Data? = nil,
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
}
