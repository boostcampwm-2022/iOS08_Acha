//
//  FirebasePath.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import Foundation

enum FirebaseRealtimeType {
    case mapList(id: Int?)
    case record(id: Int?)
    case user(id: String)
    case room(id: String)
    case postList
    case post(id: Int)
    case comment(id: Int)
    
    var path: String {
        switch self {
        case .mapList(let id):
            return id == nil ? "mapList" : "mapList/\(id)"
        case .record(let id):
            return id == nil ? "record" : "record/\(id)"
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
        }
    }
}
