//
//  User.swift
//  Acha
//
//  Created by hong on 2022/12/05.
//

import Foundation

struct User {
    let id: String
    var nickName: String
    let badges: [Int]
    let records: [Int]
    var pinCharacter: String
    let friends: [Int]
    
    init(id: String = "",
         nickName: String = "",
         badges: [Int] = [],
         records: [Int] = [],
         pinCharacter: String = "firstAnnotation",
         friends: [Int] = []) {
        self.id = id
        self.nickName = nickName
        self.badges = badges
        self.records = records
        self.pinCharacter = pinCharacter
        self.friends = friends
    }
 }
