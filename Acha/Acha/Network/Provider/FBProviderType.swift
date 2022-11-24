//
//  AchaProviderType.swift
//  Acha
//
//  Created by hong on 2022/11/24.
//

import Foundation

enum FBProviderType {
    case room(RoomDTO)
    case user(UserDTO)
}

extension FBProviderType {
    var rootUrl: String {
        return "https://acha-75e27-default-rtdb.firebaseio.com/"
    }
    
    var path: String {
        switch self {
        case .user(let userDTO):
            return rootUrl + "/\(userDTO.id)"
        case .room(let roomDTO):
            return rootUrl + "/\(roomDTO.id)"
        }
    }
    
    var HTTPHeader: [String: String] {
        switch self {
        case .room(_), .user(_):
            return ["Content-Type": "application/json"]
        }
    }
    
    var HTTPMethod: String {
        switch self {
        case .room(_), .user(_):
            return "GET"
        }
    }
    
    var HTTPBody: Data? {
        switch self {
        case .room(let roomDTO):
            return roomDTO.toJSON
        case .user(let userDTO):
            return userDTO.toJSON
        }
    }
}

extension FBProviderType {
    func toURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: toURL())
        urlRequest.allHTTPHeaderFields = HTTPHeader
        urlRequest.httpMethod = HTTPMethod
        urlRequest.httpBody = HTTPBody
        return urlRequest
    }
    
    func toURL() -> URL {
        return URL(string: path)!
    }
}
