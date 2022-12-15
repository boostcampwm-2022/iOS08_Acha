//
//  FirebaseRealtimeType.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/27.
//

import Foundation

enum FirebaseRealtimeType {
    case mapList
    case recordList
    case record(id: Int)
    case user(id: String)
    case room(id: String)
    case postList
    case post(id: Int)
    case comment(postID: Int, commentID: Int)
    case badge
    
    var path: String {
        switch self {
        case .mapList:
            return "mapList"
        case .recordList:
            return "record"
        case .record(let id):
            return "record/\(id)"
        case .user(let id):
            return "User/\(id)"
        case .room(let id):
            return "Room/\(id)"
        case .post(let id):
            return "community/postList/\(id)"
        case .postList:
            return "community/postList"
        case .comment(let postID, let commentID):
            return "community/postList/\(postID)/comments/\(commentID)"
        case .badge:
            return "badge"
        }
    }
}
