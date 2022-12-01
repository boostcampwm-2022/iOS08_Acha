//
//  UserDTO.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

struct UserDTO: Codable {
    let id: String
    let password: String
    let nickname: String
    let badges: [Int]?
    let records: [Int]?
    let pinCharacter: String?
    let friends: [Int]?
    
    func toDomain() -> User {
        return User(id: id,
                    nickName: nickname,
                    badges: badges ?? [],
                    records: records ?? [],
                    friends: friends ?? [])
    }
}
