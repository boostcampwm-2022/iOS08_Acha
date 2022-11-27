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
    
    func toURL() -> URL?
    func toURLRequest() -> URLRequest?
}
