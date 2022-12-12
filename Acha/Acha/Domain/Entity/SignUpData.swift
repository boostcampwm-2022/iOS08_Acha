//
//  SignUpData.swift
//  Acha
//
//  Created by hong on 2022/11/22.
//

import Foundation

struct SignUpData: Equatable {
    let email: String
    let password: String
    let nickName: String
    
    func toUserDTO(id: String) -> UserDTO {
        return UserDTO(id: id,
                    nickname: nickName,
                    badges: [],
                    records: [],
                    pinCharacter: nil,
                    friends: []
        )
    }
}
