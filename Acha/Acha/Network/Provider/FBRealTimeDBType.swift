//
//  FBRealTimeDBType.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation

enum FBRealTimeDBType: ProvidableType {
    
    case room(id: String, data: RoomDTO?)
    case user(id: String, data: UserDTO?)
    
    var path: String {
        switch self {
        case .room(id: let id, data: _):
            return "Room/\(id)"
        case .user(id: let id, data: _):
            return "User/\(id)"
        }
    }
    
    enum FBRealTimeDBError: Error {
        case connectError
    }
    
    var type: Encodable.Type {
        switch self {
        case .user(_, _):
            return UserDTO.self
        case .room(_, _):
            return RoomDTO.self
        }
    }
    
    var data: [String: Any]? {
        switch self {
        case .room(id: _, data: let data):
            guard let data = data else {return nil}
            return data.dictionary
        case .user(id: _, data: let data):
            guard let data = data else {return nil}
            return data.dictionary
        }
    }
    
    var id: String {
        switch self {
        case .room(id: let id, data: _):
            return id
        case .user(id: let id, data: _):
            return id
        }
    }
}

extension FBRealTimeDBType {
    func toURL() -> URL? {
        return nil
    }
    
    func toURLRequest() -> URLRequest? {
        return nil
    }
}
