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
    let text: String
    let image: String?
    let createdAt: Date
    let comments: [CommentDTO]?

}
