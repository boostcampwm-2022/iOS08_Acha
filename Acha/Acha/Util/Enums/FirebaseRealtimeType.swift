//
//  FirebaseRealtimeType.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import Foundation

enum FirebaseRealtimeType {
    case mapList
    case record
    case user(id: String)
    case room(id: String)
    case postList
    case post(id: Int)
    case comment(id: Int)
    case badge
    
    var path: String {
        switch self {
        case .mapList:
            return "mapList"
        case .record:
            return "record"
        case .user(let id):
            return "User/\(id)"
        case .room(let id):
            return "Room/\(id)"
        case .post(let id):
            return "community/postList/\(id)"
        case .postList:
            return "community/postList"
        case .comment(let id):
            return "community/postList/\(id)/comments"
        case .badge:
            return "badge"
        }
    }
}
