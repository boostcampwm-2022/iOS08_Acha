//
//  CommunityDTO.swift
//  Acha
//
//  Created by hong on 2022/12/03.
//

import Foundation

struct CommunityDTO: Codable {
    var postList: [PostDTO]?
    
    mutating func addPost(post: PostDTO) {
        postList?.append(post)
    }
}
