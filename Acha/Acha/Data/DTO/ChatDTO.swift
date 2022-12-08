//
//  ChatDTO.swift
//  Acha
//
//  Created by hong on 2022/12/08.
//

import Foundation

struct ChatDTO: Codable {
    let id: String
    let nickName: String
    let created: Date
    let text: String
    var read: [String]
    
    func toChat() -> Chat {
        return Chat(id: id, nickName: nickName, created: created, text: text)
    }
    
    func toRead() -> [String] {
        return read 
    }
    
    init(data: Chat) {
        self.id = data.id
        self.nickName = data.nickName
        self.created = data.created
        self.text = data.text
        self.read = [data.id]
    }
}
