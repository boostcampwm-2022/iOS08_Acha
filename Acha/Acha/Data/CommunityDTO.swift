//
//  CommunityDTO.swift
//  Acha
//
//  Created by hong on 2022/11/28.
//

import Foundation

struct CommunityDTO: Codable {
    var postList: [PostDTO]?
    
    mutating func addPost(post: PostDTO) {
        postList?.append(post)
    }
}
