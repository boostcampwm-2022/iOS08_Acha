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
    case newRoom(id: String, data: RoomDTO)
    
    var path: String {
        switch self {
        case .room(id: let id, data: _):
            return "Room/\(id)"
        case .user(id: let id, data: _):
            return "User/\(id)"
        default:
            return "User/"
        }
    }
    
    var restapiPath: String {
        let baseUrl = "https://acha-75e27-default-rtdb.firebaseio.com/"
        switch self {
        case .room(id: let id, data: _):
            return baseUrl + "Room/\(id).json"
        case .user(id: let id, data: _):
            return baseUrl + "Room/\(id).json"
        case .newRoom(id: let id, data: _):
            return baseUrl + "Room/\(id).json"
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
        default:
            return RoomDTO.self
        }
    }
    
    var httpHeader: [String: String]? {
        switch self {
        case .room(_), .user(_), .newRoom(_):
            return ["Content-Type": "application/json"]
        }
    }
    
    var httpMethod: String {
        switch self {
        case .room(_), .user(_):
            return "GET"
        case .newRoom(_):
            return "POST"
        }
    }
    
    var httpBody: Data? {
        switch self {
        case .room(_), .user(_):
            return nil
        case .newRoom(id: _, data: let data):
            return data.toJSON
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
        default:
            return nil
        }
    }
    
    var id: String {
        switch self {
        case .room(id: let id, data: _):
            return id
        case .user(id: let id, data: _):
            return id
        default:
            return "weatw"
        }
    }
}

extension FBRealTimeDBType {
    func toURL() -> URL? {
        return URL(string: restapiPath)
    }
    
    func toURLRequest() -> URLRequest? {
        guard let url = toURL() else {return nil}
        var urlReqeust = URLRequest(url: url)
        urlReqeust.httpMethod = httpMethod
        urlReqeust.allHTTPHeaderFields = httpHeader
        urlReqeust.httpBody = httpBody
        return urlReqeust
    }
}
