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
    case newUser(data: UserFireStoreDTO)
}

extension FBProviderType {
    var rootUrl: String {
        return "https://firestore.googleapis.com/v1/projects/acha-75e27/databases/(default)/documents"
    }
    
    var path: String {
        switch self {
        case .user (let id):
            return rootUrl + "/User/\(id)"
        case .room(let id):
            return rootUrl + "/Room/\(id)"
        case .newRoom(let data):
            return rootUrl + "/Room?documentId=\(data.id)"
        case .newUser(let data):
            return rootUrl + "/User?documentId=\(data.id.value)"
        }
    }
    
    var httpHeader: [String: String]? {
        switch self {
        case .room(_), .user(_), .newUser(data: _), .newRoom(data: _):
            return ["Content-Type": "application/json"]
        }
    }
    
    var httpMethod: String {
        switch self {
        case .room(_), .user(_):
            return "GET"
        case .newRoom(data: _), .newUser(data: _):
            return "POST"
        }
    }
    
    var httpBody: Data? {
        switch self {
        case .room(_), .user(_):
            return nil
        case .newUser(data: let data):
            return data.toJSON
        case .newRoom(data: let data):
            return data.toJSON
        }
    }
    
    var data: [String: Any]? {
        return nil
    }
    
    var id: String {
        switch self {
        case .user(id: let id):
            return id
        case .room(id: let id):
            return id
        case .newUser(data: let data):
            return data.id.value
        case .newRoom(data: let data):
            return data.id
        }
    }
}

extension FBProviderType {
    func toURLRequest() -> URLRequest? {
        guard let url = toURL() else {return nil}
        var urlRequest = URLRequest(url: url)
        httpHeader?.forEach({ header in
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        })
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = httpBody
        return urlRequest
    }
    
    func toURL() -> URL? {
        return URL(string: path)
    }
}
