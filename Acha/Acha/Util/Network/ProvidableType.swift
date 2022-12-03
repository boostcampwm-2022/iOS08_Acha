//
//  ProvidableType.swift
//  Acha
//
//  Created by hong on 2022/11/27.
//

import Foundation

protocol ProvidableType {
    var path: String {get}
    var id: String {get}
    var httpHeader: [String: String]? {get}
    var httpBody: Data? {get}
    var httpMethod: String {get}
    var data: [String: Any]? {get}
    
    func toURL() -> URL?
    func toURLRequest() -> URLRequest?
}
