//
//  Comment.swift
//  Acha
//
//  Created by hong on 2022/11/29.
//

import Foundation

struct Comment: Hashable {
    let postID: Int
    let commentID: Int
    let userID: String
    let nickName: String
    let text: String
    let createdAt: Date
}
