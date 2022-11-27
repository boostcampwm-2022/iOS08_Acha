//
//  AchaProviderType.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation

enum FBProviderType: ProvidableType {
    case room(id: String)
    case user(id: String)
    case newRoom(data: RoomDTO)
    case newUser(data: UserDTO)
}

extension FBProviderType {
    var rootUrl: String {
        return "https://firestore.googleapis.com/v1/projects/acha-75e27/databases/(default)/documents/Acha"
    }
    
    var path: String {
        switch self {
        case .user (let id):
            return rootUrl + "/User/\(id)"
        case .room(let id):
            return rootUrl + "/Room/\(id)"
        case .newRoom(let data):
            return rootUrl + "/Room/\(data.id)"
        case .newUser(let data):
            return rootUrl + "/User/\(data.id)"
        }
    }
    
    var HTTPHeader: [String: String] {
        switch self {
        case .room(_), .user(_), .newUser(data: _), .newRoom(data: _):
            return ["Content-Type": "application/json"]
        }
    }
    
    var HTTPMethod: String {
        switch self {
        case .room(_), .user(_):
            return "GET"
        case .newRoom(data: _), .newUser(data: _):
            return "POST"
        }
    }
    
    var HTTPBody: Data? {
        switch self {
        case .room(_), .user(_):
            return nil
        case .newUser(data: let data):
            return data.toJSON
        case .newRoom(data: let data):
            return data.toJSON
        }
    }
    
    var id: String {
        switch self {
        case .user(id: let id):
            return id
        case .room(id: let id):
            return id
        case .newUser(data: let data):
            return data.id
        case .newRoom(data: let data):
            return data.id
        }
    }
}

extension FBProviderType {
    func toURLRequest() -> URLRequest? {
        guard let url = toURL() else {return nil}
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = HTTPHeader
        urlRequest.httpMethod = HTTPMethod
        urlRequest.httpBody = HTTPBody
        return urlRequest
    }
    
    func toURL() -> URL? {
        return URL(string: path)
    }
}
