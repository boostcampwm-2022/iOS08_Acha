//
//  Post.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct Post: Hashable {
    let id: Int
    let userID: String
    let nickName: String
    let text: String
    let image: String?
    let createdAt: Date
    let comments: [Comment]
}
